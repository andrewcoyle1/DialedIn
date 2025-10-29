//
//  WorkoutSessionDetailViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol WorkoutSessionDetailInteractor {
    var currentUser: UserModel? { get }
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws
    func updateWorkoutSession(session: WorkoutSessionModel) async throws
    func getPreference(templateId: String) -> ExerciseUnitPreference
    func setPreference(weightUnit: ExerciseWeightUnit?, distanceUnit: ExerciseDistanceUnit?, for templateId: String)
    func deleteLocalWorkoutSession(id: String) throws
    func deleteWorkoutSession(id: String) async throws
}

extension CoreInteractor: WorkoutSessionDetailInteractor { }

@Observable
@MainActor
class WorkoutSessionDetailViewModel {
    private let interactor: WorkoutSessionDetailInteractor
    
    private(set) var isEditMode = false
    private(set) var exerciseUnitPreferences: [String: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)] = [:]
    
    var showAlert: AnyAppAlert?
    var isDeleting = false
    var session: WorkoutSessionModel
    var editedSession: WorkoutSessionModel
    var isSaving = false
    var showAddExerciseSheet = false
    var isLoading: Bool {
        isSaving || isDeleting
    }
    var selectedExerciseTemplates: [ExerciseTemplateModel] = []
    
    var currentSession: WorkoutSessionModel {
        isEditMode ? editedSession : session
    }
    
    var hasUnsavedChanges: Bool {
        editedSession != session
    }
    
    init(
        interactor: WorkoutSessionDetailInteractor,
        session: WorkoutSessionModel
    ) {
        self.interactor = interactor
        self.session = session
        self.editedSession = session
    }
    
    var totalSets: Int {
        currentSession.exercises.flatMap { $0.sets }.filter { !$0.isWarmup }.count
    }
    
    var totalVolume: Double {
        currentSession.exercises.flatMap { $0.sets }
            .filter { !$0.isWarmup }
            .compactMap { set -> Double? in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }.reduce(0.0, +)
    }
    
    var volumeFormatted: String {
        if totalVolume > 0 {
            return String(format: "%.0f kg", totalVolume)
        } else {
            return "—"
        }
    }
    
    // MARK: - Edit Mode Actions
    
    func enterEditMode() {
        editedSession = session
        isEditMode = true
        loadUnitPreferences()
    }
    
    func cancelEditing() {
        editedSession = session
        isEditMode = false
    }
    
    func showDiscardChangesAlert() {
        showAlert = AnyAppAlert(
            title: "Discard changes?",
            subtitle: "You have unsaved changes. This will discard them.",
            buttons: {
                AnyView(
                    VStack {
                        Button("Discard Changes", role: .destructive) {
                            self.cancelEditing()
                            self.showAlert = nil
                        }
                        Button("Keep Editing", role: .cancel) {
                            self.showAlert = nil
                        }
                    }
                )
            }
        )
    }
    
    func saveChanges(onDismiss: @escaping @MainActor () -> Void) async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            // Update dateModified using the model's method
            var sessionToSave = editedSession
            sessionToSave.updateExercises(sessionToSave.exercises)
            
            // Save to local first
            try interactor.updateLocalWorkoutSession(session: sessionToSave)
            
            // Save to Firebase
            try await interactor.updateWorkoutSession(session: sessionToSave)
            
            isEditMode = false
            
            // Dismiss to refresh parent view
            onDismiss()
        } catch {
            showAlert = AnyAppAlert(
                title: "Save Failed",
                subtitle: "Unable to save changes. Please try again."
            )
        }
    }
    
    // MARK: - Exercise Updates
    
    func updateExercise(at index: Int, with updated: WorkoutExerciseModel) {
        var updatedExercises = editedSession.exercises
        updatedExercises[index] = updated
        editedSession.updateExercises(updatedExercises)
    }
    
    // MARK: - Set Management
    
    func addSet(to exerciseId: String) {
        guard let exerciseIndex = editedSession.exercises.firstIndex(where: { $0.id == exerciseId }),
              let userId = interactor.currentUser?.userId else {
            return
        }
        
        var updatedExercises = editedSession.exercises
        let exercise = updatedExercises[exerciseIndex]
        let newIndex = exercise.sets.count + 1
        
        // Create new set based on the last set's values or default
        let lastSet = exercise.sets.last
        let newSet = WorkoutSetModel(
            id: UUID().uuidString,
            authorId: userId,
            index: newIndex,
            reps: lastSet?.reps,
            weightKg: lastSet?.weightKg,
            durationSec: lastSet?.durationSec,
            distanceMeters: lastSet?.distanceMeters,
            rpe: lastSet?.rpe,
            isWarmup: false,
            completedAt: Date(),
            dateCreated: Date()
        )
        
        updatedExercises[exerciseIndex].sets.append(newSet)
        editedSession.updateExercises(updatedExercises)
    }
    
    func deleteSet(_ setId: String, from exerciseId: String) {
        guard let exerciseIndex = editedSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = editedSession.exercises
        updatedExercises[exerciseIndex].sets.removeAll { $0.id == setId }
        
        // Reindex remaining sets
        for index in updatedExercises[exerciseIndex].sets.indices {
            updatedExercises[exerciseIndex].sets[index].index = index + 1
        }
        
        editedSession.updateExercises(updatedExercises)
    }
    
    // MARK: - Exercise Management
    
    func deleteExercise(id: String) {
        var updatedExercises = editedSession.exercises
        updatedExercises.removeAll { $0.id == id }
        
        // Reindex remaining exercises
        for index in updatedExercises.indices {
            updatedExercises[index].index = index + 1
        }
        
        editedSession.updateExercises(updatedExercises)
    }
    
    func addSelectedExercises() {
        guard !selectedExerciseTemplates.isEmpty, let userId = interactor.currentUser?.userId else {
            return
        }
        
        var updated = editedSession.exercises
        let startIndex = updated.count
        
        for (offset, template) in selectedExerciseTemplates.enumerated() {
            let index = startIndex + offset + 1
            let mode = WorkoutSessionModel.trackingMode(for: template.type)
            let defaultSets = WorkoutSessionModel.defaultSets(trackingMode: mode, authorId: userId)
            let imageName = Constants.exerciseImageName(for: template.name)
            
            let newExercise = WorkoutExerciseModel(
                id: UUID().uuidString,
                authorId: userId,
                templateId: template.id,
                name: template.name,
                trackingMode: mode,
                index: index,
                notes: nil,
                imageName: imageName,
                sets: defaultSets
            )
            updated.append(newExercise)
        }
        
        editedSession.updateExercises(updated)
        selectedExerciseTemplates.removeAll()
    }
    
    // MARK: - Unit Preferences
    
    func loadUnitPreferences() {
        for exercise in editedSession.exercises {
            let preference = interactor.getPreference(templateId: exercise.templateId)
            exerciseUnitPreferences[exercise.templateId] = (
                weightUnit: preference.weightUnit,
                distanceUnit: preference.distanceUnit
            )
        }
    }
    
    func getUnitPreference(for templateId: String) -> (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit) {
        if let cached = exerciseUnitPreferences[templateId] {
            return cached
        }
        let preference = interactor.getPreference(templateId: templateId)
        let result = (weightUnit: preference.weightUnit, distanceUnit: preference.distanceUnit)
        exerciseUnitPreferences[templateId] = result
        return result
    }
    
    func updateWeightUnit(_ unit: ExerciseWeightUnit, for templateId: String) {
        var current = getUnitPreference(for: templateId)
        current.weightUnit = unit
        exerciseUnitPreferences[templateId] = current
        interactor.setPreference(weightUnit: unit, distanceUnit: current.distanceUnit, for: templateId)
    }
    
    func updateDistanceUnit(_ unit: ExerciseDistanceUnit, for templateId: String) {
        var current = getUnitPreference(for: templateId)
        current.distanceUnit = unit
        exerciseUnitPreferences[templateId] = current
        interactor.setPreference(weightUnit: current.weightUnit, distanceUnit: unit, for: templateId)
    }
    
    // MARK: - Delete Session
    
    func onDeletePressed(onDismiss: () -> Void) {
        Task {
            await deleteSession(session: self.session)
        }
        onDismiss()
    }
    
    func deleteSession(session: WorkoutSessionModel) async {
        isDeleting = true
        defer { isDeleting = false }
        
        do {
            // Delete from local first for instant feedback
            try interactor.deleteLocalWorkoutSession(id: session.id)
            
            // Delete from remote in background
            try await interactor.deleteWorkoutSession(id: session.id)
        } catch {
            showAlert = AnyAppAlert(
                title: "Delete Failed",
                subtitle: "Unable to delete workout session. Please try again.",
                buttons: {
                    AnyView(
                        HStack {
                            Button("Cancel") { }
                            Button("Try Again") {
                                Task {
                                    await self.deleteSession(
                                        session: session
                                    )
                                }
                            }
                        }
                    )
                }
            )
        }
    }
}

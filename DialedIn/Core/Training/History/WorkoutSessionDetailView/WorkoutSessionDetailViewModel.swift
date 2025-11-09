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
    func markWorkoutIncompleteIfSessionDeleted(scheduledWorkoutId: String, sessionId: String) async throws
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
    var editedSession: WorkoutSessionModel?
    var isSaving = false
    var showAddExerciseSheet = false
    var isLoading: Bool {
        isSaving || isDeleting
    }
    var selectedExerciseTemplates: [ExerciseTemplateModel] = []
    
    func currentSession(session: WorkoutSessionModel) -> WorkoutSessionModel {
        isEditMode ? editedSession ?? session : session
    }
    
    func hasUnsavedChanges(session: WorkoutSessionModel) -> Bool {
        editedSession != session
    }
    
    init(interactor: WorkoutSessionDetailInteractor) {
        self.interactor = interactor
    }
    
    func totalSets(session: WorkoutSessionModel) -> Int {
        currentSession(session: session)
            .exercises
            .flatMap { $0.sets }
            .filter { !$0.isWarmup }
            .count
    }
    
    func totalVolume(session: WorkoutSessionModel) -> Double {
        currentSession(session: session)
            .exercises
            .flatMap { $0.sets }
            .filter { !$0.isWarmup }
            .compactMap { set -> Double? in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            .reduce(0.0, +)
    }
    
    func volumeFormatted(session: WorkoutSessionModel) -> String {
        let volume = totalVolume(session: session)
        if volume > 0 {
            return String(format: "%.0f kg", volume)
        } else {
            return "—"
        }
    }
    
    // MARK: - Edit Mode Actions
    
    func enterEditMode(session: WorkoutSessionModel) {
        editedSession = session
        isEditMode = true
        loadUnitPreferences(for: session)
    }
    
    func cancelEditing(session: WorkoutSessionModel) {
        editedSession = session
        isEditMode = false
    }
    
    func showDiscardChangesAlert(session: WorkoutSessionModel) {
        showAlert = AnyAppAlert(
            title: "Discard changes?",
            subtitle: "You have unsaved changes. This will discard them.",
            buttons: {
                AnyView(
                    VStack {
                        Button("Discard Changes", role: .destructive) {
                            self.cancelEditing(session: session)
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
            guard var sessionToSave = editedSession else {
                isEditMode = false
                onDismiss()
                return
            }
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
        guard var session = editedSession else { return }
        guard session.exercises.indices.contains(index) else { return }
        
        var updatedExercises = session.exercises
        updatedExercises[index] = updated
        session.updateExercises(updatedExercises)
        editedSession = session
    }
    
    // MARK: - Set Management
    
    func addSet(to exerciseId: String) {
        guard var session = editedSession,
              let exerciseIndex = session.exercises.firstIndex(where: { $0.id == exerciseId }),
              let userId = interactor.currentUser?.userId else {
            return
        }
        
        var updatedExercises = session.exercises
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
        session.updateExercises(updatedExercises)
        editedSession = session
    }
    
    func deleteSet(_ setId: String, from exerciseId: String) {
        guard var session = editedSession,
              let exerciseIndex = session.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = session.exercises
        updatedExercises[exerciseIndex].sets.removeAll { $0.id == setId }
        
        // Reindex remaining sets
        for index in updatedExercises[exerciseIndex].sets.indices {
            updatedExercises[exerciseIndex].sets[index].index = index + 1
        }
        
        session.updateExercises(updatedExercises)
        editedSession = session
    }
    
    // MARK: - Exercise Management
    
    func deleteExercise(id: String) {
        guard var session = editedSession else { return }
        
        var updatedExercises = session.exercises
        updatedExercises.removeAll { $0.id == id }
        
        // Reindex remaining exercises
        for index in updatedExercises.indices {
            updatedExercises[index].index = index + 1
        }
        
        session.updateExercises(updatedExercises)
        editedSession = session
    }
    
    func addSelectedExercises() {
        guard !selectedExerciseTemplates.isEmpty,
              var session = editedSession,
              let userId = interactor.currentUser?.userId else {
            return
        }
        
        var updated = session.exercises
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
        
        session.updateExercises(updated)
        editedSession = session
        selectedExerciseTemplates.removeAll()
    }
    
    // MARK: - Unit Preferences
    
    func loadUnitPreferences(for session: WorkoutSessionModel) {
        exerciseUnitPreferences.removeAll(keepingCapacity: true)
        
        for exercise in currentSession(session: session).exercises {
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
    
    func onDeletePressed(session: WorkoutSessionModel, onDismiss: () -> Void) {
        Task {
            await deleteSession(session: session)
        }
        onDismiss()
    }
    
    func deleteSession(session: WorkoutSessionModel) async {
        isDeleting = true
        defer { isDeleting = false }
        
        do {
            // If this session is linked to a scheduled workout, unmark it as complete
            // Only if this session was the one that completed it
            if let scheduledWorkoutId = session.scheduledWorkoutId {
                try? await interactor.markWorkoutIncompleteIfSessionDeleted(
                    scheduledWorkoutId: scheduledWorkoutId,
                    sessionId: session.id
                )
            }
            
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

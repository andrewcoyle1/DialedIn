//
//  WorkoutSessionDetailPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutSessionDetailPresenter {
    private let interactor: WorkoutSessionDetailInteractor
    private let router: WorkoutSessionDetailRouter

    private(set) var isEditMode = false
    private(set) var exerciseUnitPreferences: [String: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)] = [:]
        
    var isSaving: Bool = false
    var isLoading: Bool {
        isSaving
    }
    
    var selectedExerciseModels: [WorkoutTemplateExercise] = []
    
    func isAuthor(sessionAuthorId: String?) -> Bool {
        interactor.currentUser?.userId == sessionAuthorId
    }
        
    func hasUnsavedChanges(session: WorkoutSessionModel, editedSession: WorkoutSessionModel) -> Bool {
        editedSession != session
    }
    
    init(
        interactor: WorkoutSessionDetailInteractor,
        router: WorkoutSessionDetailRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func totalSets(session: WorkoutSessionModel) -> Int {
        session
            .exercises
            .flatMap { $0.sets }
            .filter { !$0.isWarmup }
            .count
    }
    
    func totalVolume(session: WorkoutSessionModel) -> Double {
        session
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
        isEditMode = true
        loadUnitPreferences(for: session)
    }
        
    func showDiscardChangesAlert(session: WorkoutSessionModel) {
        router.showAlert(
            title: "Discard changes?",
            subtitle: "You have unsaved changes. This will discard them.",
            buttons: {
                AnyView(
                    VStack {
                        Button("Discard Changes", role: .destructive) {
                            self.onDismissPressed()
                        }
                        Button("Keep Editing", role: .cancel) {

                        }
                    }
                )
            }
        )
    }
    
    func onDismissPressed() {
        self.dismissScreen()
    }

    private func dismissScreen() {
        router.dismissScreen()
    }

    func saveChanges(initialSession: WorkoutSessionModel, session: Binding<WorkoutSessionModel>) async {
        router.showLoadingModal()
        isSaving = true
        defer {
            router.dismissModal()
            isSaving = false
        }
        
        do {
            // Update dateModified using the model's method
            guard initialSession != session.wrappedValue else {
                isEditMode = false
                dismissScreen()
                return
            }
            session.wrappedValue.updateExercises(session.wrappedValue.exercises)
            
            try await interactor.saveWorkoutSession(session.wrappedValue)
            
            isEditMode = false
            
            // Dismiss to refresh parent view
            dismissScreen()
        } catch {
            router.showSimpleAlert(
                title: "Save Failed",
                subtitle: "Unable to save changes. Please try again."
            )
        }
    }
    
    // MARK: - Exercise Updates
    
    func updateExercise(session: Binding<WorkoutSessionModel>, at index: Int, with updated: WorkoutExerciseModel) {
        guard session.wrappedValue.exercises.indices.contains(index) else { return }
        
        var updatedExercises = session.wrappedValue.exercises
        updatedExercises[index] = updated
        session.wrappedValue.updateExercises(updatedExercises)
    }
    
    // MARK: - Set Management
    
    func addSet(session: Binding<WorkoutSessionModel>, to exerciseId: String) {
        
        guard let exerciseIndex = session.wrappedValue.exercises.firstIndex(where: { $0.id == exerciseId }),
        let userId = interactor.currentUser?.userId else { return }
        var updatedExercises = session.wrappedValue.exercises
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
        session.wrappedValue.updateExercises(updatedExercises)
    }
    
    func deleteSet(session: Binding<WorkoutSessionModel>, _ setId: String, from exerciseId: String) {
        guard let exerciseIndex = session.wrappedValue.exercises.firstIndex(where: { $0.id == exerciseId }) else { return }
        
        var updatedExercises = session.wrappedValue.exercises
        updatedExercises[exerciseIndex].sets.removeAll { $0.id == setId }
        
        // Reindex remaining sets
        for index in updatedExercises[exerciseIndex].sets.indices {
            updatedExercises[exerciseIndex].sets[index].index = index + 1
        }
        
        session.wrappedValue.updateExercises(updatedExercises)
    }
    
    // MARK: - Exercise Management
    
    func deleteExercise(session: Binding<WorkoutSessionModel>, id: String) {
        
        var updatedExercises = session.wrappedValue.exercises
        updatedExercises.removeAll { $0.id == id }
        
        // Reindex remaining exercises
        for index in updatedExercises.indices {
            updatedExercises[index].index = index + 1
        }
        
        session.wrappedValue.updateExercises(updatedExercises)
    }
    
    func addSelectedExercises(session: Binding<WorkoutSessionModel>) {
        guard !selectedExerciseModels.isEmpty,
              let userId = interactor.currentUser?.userId else {
            return
        }
        
        var updated = session.wrappedValue.exercises
        let startIndex = updated.count
        
        for (offset, template) in selectedExerciseModels.enumerated() {
            let index = startIndex + offset + 1
            let mode = WorkoutSessionModel.trackingMode(for: template.exercise)
            let targetCount = max(template.setTargets.count, 1)
            let defaultSets = WorkoutSessionModel.defaultSets(trackingMode: mode, authorId: userId, targetCount: targetCount)
            let imageName = Constants.exerciseImageName(for: template.exercise.name)
            
            let newExercise = WorkoutExerciseModel(
                id: UUID().uuidString,
                authorId: userId,
                templateId: template.exercise.id,
                name: template.exercise.name,
                trackingMode: mode,
                index: index,
                notes: nil,
                imageName: imageName,
                sets: defaultSets
            )
            updated.append(newExercise)
        }
        
        session.wrappedValue.updateExercises(updated)
        selectedExerciseModels.removeAll()
    }
    
    // MARK: - Unit Preferences
    
    func loadUnitPreferences(for session: WorkoutSessionModel) {
        exerciseUnitPreferences.removeAll(keepingCapacity: true)
        
        for exercise in session.exercises {
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
    
    func onDeletePressed(session: WorkoutSessionModel) {
        router.showAlert(
            title: "Delete Workout?",
            subtitle: "Are you sure you want to delete this workout? This cannot be undone.") {
                AnyView(
                    HStack {
                        Button(role: .cancel) { }
                        Button(role: .destructive) {
                            self.deleteSession(session: session)
                        }
                    }
                )
            }
    }

    func deleteSession(session: WorkoutSessionModel) {
        router.dismissScreen()
        Task {
            try? await interactor.deleteWorkoutSession(id: session.id)
        }
    }

    func onAddExercisePressed() {
        router.showExercisesPickerView(
            delegate: ExercisesPickerDelegate(
                addedExercises: Binding(
                    get: {
                        self.selectedExerciseModels
                    },
                    set: { newValue in
                        self.selectedExerciseModels = newValue
                    }
                )
            )
        )
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}


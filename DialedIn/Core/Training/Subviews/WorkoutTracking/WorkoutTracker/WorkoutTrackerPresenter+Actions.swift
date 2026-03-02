//
//  WorkoutTrackerPresenter+Actions.swift
//  DialedIn
//
//  Extracted for type_body_length and file_length.
//

import SwiftUI
import HealthKit

// MARK: - Widget Sync, Sets, Rest, Exercise Management, Validation
extension WorkoutTrackerPresenter {

    // MARK: - Widget Sync
    func startWidgetSyncTimer() {
        if widgetSyncTimer != nil { return }
        widgetSyncTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.syncPendingSetCompletionFromWidget()
                self?.syncPendingWorkoutCompletionFromWidget()
            }
        }
    }

    func stopWidgetSyncTimer() {
        guard widgetSyncTimer != nil else {
            return
        }
        widgetSyncTimer?.invalidate()
        widgetSyncTimer = nil
    }

    func syncPendingSetCompletionFromWidget() {
        guard let pending = SharedWorkoutStorage.pendingSetCompletion else { return }

        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { exercise in
            exercise.sets.contains { $0.id == pending.setId }
        }) else {
            SharedWorkoutStorage.clearPendingSetCompletion()
            return
        }

        guard let setIndex = workoutSession.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == pending.setId }) else {
            SharedWorkoutStorage.clearPendingSetCompletion()
            return
        }

        let exercise = workoutSession.exercises[exerciseIndex]
        var updatedSet = exercise.sets[setIndex]

        if let weight = pending.weightKg { updatedSet.weightKg = weight }
        if let reps = pending.reps { updatedSet.reps = reps }
        if let distance = pending.distanceMeters { updatedSet.distanceMeters = distance }
        if let duration = pending.durationSec { updatedSet.durationSec = duration }
        updatedSet.completedAt = pending.completedAt

        SharedWorkoutStorage.clearPendingSetCompletion()
        updateSet(updatedSet, in: exercise.id)
    }

    func updateSet(_ updatedSet: WorkoutSetModel, in exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }),
              let setIndex = workoutSession.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == updatedSet.id }) else {
            return
        }
        let exerciseBefore = workoutSession.exercises[exerciseIndex]
        let wasExerciseCompleteBefore = !exerciseBefore.sets.isEmpty && exerciseBefore.sets.allSatisfy { $0.completedAt != nil }

        var updatedExercises = workoutSession.exercises
        let previousCompletedAt = updatedExercises[exerciseIndex].sets[setIndex].completedAt
        updatedExercises[exerciseIndex].sets[setIndex] = updatedSet

        // Propagate weight/reps changes to uncompleted sibling sets with matching values
        if interactor.workoutSettings.propagateChanges {
            let original = exerciseBefore.sets[setIndex]
            let weightChanged = original.weightKg != updatedSet.weightKg
            let repsChanged = original.reps != updatedSet.reps
            if (weightChanged || repsChanged) && updatedSet.completedAt == nil {
                for index in updatedExercises[exerciseIndex].sets.indices where index != setIndex {
                    var sibling = updatedExercises[exerciseIndex].sets[index]
                    guard sibling.completedAt == nil,
                          sibling.weightKg == original.weightKg,
                          sibling.reps == original.reps else { continue }
                    if weightChanged { sibling.weightKg = updatedSet.weightKg }
                    if repsChanged { sibling.reps = updatedSet.reps }
                    updatedExercises[exerciseIndex].sets[index] = sibling
                }
            }
        }

        let isExerciseCompleteNow = !updatedExercises[exerciseIndex].sets.isEmpty && updatedExercises[exerciseIndex].sets.allSatisfy { $0.completedAt != nil }
        workoutSession.updateExercises(updatedExercises)

        let allSets = updatedExercises.flatMap { $0.sets }
        let isAllSetsComplete = !allSets.isEmpty && allSets.allSatisfy { $0.completedAt != nil }

        if previousCompletedAt == nil, updatedSet.completedAt != nil, !isAllSetsComplete,
           interactor.workoutSettings.useRestTimers {
            let customForThisSet = restBeforeSetIdToSec[updatedSet.id]
            startRestTimer(durationSeconds: customForThisSet ?? restDurationSeconds)
        }

        if !wasExerciseCompleteBefore && isExerciseCompleteNow {
            let nextIndex = exerciseIndex + 1
            if nextIndex < updatedExercises.count && interactor.workoutSettings.exerciseAutoNext {
                expandedExerciseIds.removeAll()
                expandedExerciseIds.insert(updatedExercises[nextIndex].id)
                currentExerciseIndex = nextIndex
            } else if nextIndex >= updatedExercises.count {
                expandedExerciseIds.remove(updatedExercises[exerciseIndex].id)
            }
        }

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(params: LiveActivityUpdateParams(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        ))
        #endif
    }

    func addSet(exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }),
              let userId = interactor.currentUser?.userId else {
            return
        }

        var updatedExercises = workoutSession.exercises
        let existingSets = updatedExercises[exerciseIndex].sets
        let newIndex = existingSets.count + 1
        let lastSet = existingSets.last

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
            completedAt: nil,
            dateCreated: Date()
        )

        updatedExercises[exerciseIndex].sets.append(newSet)
        workoutSession.updateExercises(updatedExercises)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(params: LiveActivityUpdateParams(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        ))
        #endif
    }

    func deleteSet(setId: String, exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }

        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].sets.removeAll { $0.id == setId }

        for index in updatedExercises[exerciseIndex].sets.indices {
            updatedExercises[exerciseIndex].sets[index].index = index + 1
        }

        workoutSession.updateExercises(updatedExercises)
        restBeforeSetIdToSec.removeValue(forKey: setId)
        syncCurrentExerciseIndexToFirstIncomplete(in: updatedExercises)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(params: LiveActivityUpdateParams(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        ))
        #endif
    }

    func updateExerciseNotes(_ notes: String, exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }

        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].notes = notes.isEmpty ? nil : notes
        workoutSession.updateExercises(updatedExercises)
    }

    func updateRestBefore(setId: String, seconds: Int?) {
        if let seconds {
            restBeforeSetIdToSec[setId] = seconds
        } else {
            restBeforeSetIdToSec.removeValue(forKey: setId)
        }
    }

    func onRestPickerRequested(setId: String) {
        restPickerTargetSetId = setId
        let existing = restBeforeSetIdToSec[setId] ?? restDurationSeconds
        restPickerMinutesSelection = existing / 60
        restPickerSecondsSelection = existing % 60

        router.showRestModal(
            primaryButtonAction: { [weak self] in
                guard let self else { return }
                let totalSeconds = (self.restPickerMinutesSelection * 60) + self.restPickerSecondsSelection
                self.updateRestBefore(setId: setId, seconds: totalSeconds > 0 ? totalSeconds : nil)
                self.router.dismissModal()
            },
            secondaryButtonAction: { [weak self] in
                self?.router.dismissModal()
            },
            minutesSelection: Binding(
                get: { self.restPickerMinutesSelection },
                set: { self.restPickerMinutesSelection = $0 }
            ),
            secondsSelection: Binding(
                get: { self.restPickerSecondsSelection },
                set: { self.restPickerSecondsSelection = $0 }
            )
        )
    }

    func startRestTimer(durationSeconds: Int = 0) {
        let duration = durationSeconds > 0 ? durationSeconds : restDurationSeconds
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.startRest(durationSeconds: duration, session: workoutSession, currentExerciseIndex: currentExerciseIndex)

        // Schedule local notification for when rest is complete
        if let endTime = interactor.restEndTime {
            Task {
                do {
                    let delegate = PushNotificationDelegate(
                        identifier: restTimerNotificationId,
                        title: "Rest Complete",
                        subtitle: "Time to get back to your workout!",
                        triggerDate: endTime,
                        sound: true,
                        badge: nil
                    )
                    try await interactor.schedulePushNotification(delegate: delegate)
                } catch {
                    // Silently fail - notification is nice to have but not critical
                }
            }
        }
        #endif
    }

    func syncPendingWorkoutCompletionFromWidget() {
        guard let pending = SharedWorkoutStorage.pendingWorkoutCompletion else { return }

        guard pending.sessionId == workoutSession.id else {
            SharedWorkoutStorage.clearPendingWorkoutCompletion()
            return
        }

        SharedWorkoutStorage.clearPendingWorkoutCompletion()
    }

    func onGymProfilePressed() {
        guard let gymProfile = favouriteGymProfile else { return }
        let delegate = GymProfileDelegate(gymProfile: gymProfile)
        router.showGymProfileView(delegate: delegate)
    }

    // MARK: - Exercise Management
    func addSelectedExercises() {
        let templates = self.pendingSelectedTemplates
        guard !templates.isEmpty, let userId = interactor.currentUser?.userId else { return }
        var updated = workoutSession.exercises
        let startIndex = updated.count
        for (offset, template) in templates.enumerated() {
            let index = startIndex + offset + 1
            let mode = WorkoutSessionModel.trackingMode(for: template)
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
        workoutSession.updateExercises(updated)
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)
        if currentExerciseIndex < updated.count {
            expandedExerciseIds.removeAll()
            expandedExerciseIds.insert(updated[currentExerciseIndex].id)
        }

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(params: LiveActivityUpdateParams(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        ))
        #endif

        self.pendingSelectedTemplates = []
    }

    func deleteExercise(_ exerciseId: String) {
        var updated = workoutSession.exercises
        guard let idx = updated.firstIndex(where: { $0.id == exerciseId }) else { return }
        updated.remove(at: idx)
        for index in updated.indices { updated[index].index = index + 1 }
        workoutSession.updateExercises(updated)
        expandedExerciseIds.remove(exerciseId)
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(params: LiveActivityUpdateParams(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        ))
        #endif
    }

    func onWorkoutSettingsPressed() {
        router.showWorkoutSettingsView(delegate: WorkoutSettingsDelegate())
    }

    func moveExercises(from source: IndexSet, to destination: Int) {
        var updated = workoutSession.exercises
        updated.move(fromOffsets: source, toOffset: destination)
        applyReorderedExercises(updated, movedFrom: source.first, movedTo: destination)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(params: LiveActivityUpdateParams(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        ))
        #endif
    }

    func onExerciseEquipmentPressed(_ exercise: WorkoutExerciseModel) {
        let delegate = WorkoutExerciseEquipmentSheetDelegate(exercise: exercise) { [weak self] resistance, support in
            guard let self else { return }
            guard let idx = workoutSession.exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
            var updated = workoutSession.exercises
            let updatedExercise = WorkoutExerciseModel(
                id: exercise.id,
                authorId: exercise.authorId,
                templateId: exercise.templateId,
                name: exercise.name,
                trackingMode: exercise.trackingMode,
                index: exercise.index,
                notes: exercise.notes,
                imageName: exercise.imageName,
                sets: exercise.sets,
                setTargets: exercise.setTargets,
                chosenResistanceEquipment: resistance,
                chosenSupportEquipment: support
            )
            updated[idx] = updatedExercise
            workoutSession.updateExercises(updated)
        }
        router.showWorkoutExerciseEquipmentSheetView(delegate: delegate)
    }

    func reorderExercises(from sourceIndex: Int, to targetIndex: Int) {
        guard sourceIndex != targetIndex else { return }
        var updated = workoutSession.exercises
        let element = updated.remove(at: sourceIndex)
        updated.insert(element, at: targetIndex)
        applyReorderedExercises(updated, movedFrom: sourceIndex, movedTo: targetIndex)
    }

    func buttonColor(set: WorkoutSetModel, canComplete: Bool) -> Color {
        if set.completedAt != nil {
            return .green
        } else if canComplete {
            return .secondary
        } else {
            return .red.opacity(0.6)
        }
    }

    func canComplete(trackingMode: TrackingMode, set: WorkoutSetModel) -> Bool {
        switch trackingMode {
        case .weightReps:
            let hasValidWeight = set.weightKg == nil || set.weightKg! >= 0
            let hasValidReps = set.reps != nil && set.reps! > 0
            return hasValidWeight && hasValidReps

        case .repsOnly:
            return set.reps != nil && set.reps! > 0

        case .timeOnly:
            return set.durationSec != nil && set.durationSec! > 0

        case .distanceTime:
            let hasValidDistance = set.distanceMeters != nil && set.distanceMeters! > 0
            let hasValidTime = set.durationSec != nil && set.durationSec! > 0
            return hasValidDistance && hasValidTime
        }
    }

    func validateSetData(trackingMode: TrackingMode, set: WorkoutSetModel) -> Bool {
        switch trackingMode {
        case .weightReps:
            return validateWeightReps(set: set)
        case .repsOnly:
            return validateRepsOnly(set: set)
        case .timeOnly:
            return validateTimeOnly(set: set)
        case .distanceTime:
            return validateDistanceTime(set: set)
        }
    }

    func validateWeightReps(set: WorkoutSetModel) -> Bool {
        // Weight must be non-negative (including 0 for bodyweight exercises)
        if let weight = set.weightKg, weight < 0 {
            router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Weight must be a non-negative number")
            return false
        }

        // Reps must be positive
        guard let reps = set.reps, reps > 0 else {
            router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Reps must be a positive number")
            return false
        }

        return true
    }

    func validateRepsOnly(set: WorkoutSetModel) -> Bool {
        // Reps must be positive
        guard let reps = set.reps, reps > 0 else {
            router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Reps must be a positive number")
            return false
        }

        return true
    }

    func validateTimeOnly(set: WorkoutSetModel) -> Bool {
        // Time must be positive
        guard let duration = set.durationSec, duration > 0 else {
            router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Duration must be a positive time")
            return false
        }

        return true
    }

    func validateDistanceTime(set: WorkoutSetModel) -> Bool {
        // Distance must be positive
        guard let distance = set.distanceMeters, distance > 0 else {
            router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Distance must be a positive number")
            return false
        }

        // Time must be positive
        guard let duration = set.durationSec, duration > 0 else {
            router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Duration must be a positive time")
            return false
        }

        return true
    }

    func onWarmupSetHelpPressed() {
        router.showWarmupSetInfoModal {
            self.router.dismissModal()
        }
    }
}

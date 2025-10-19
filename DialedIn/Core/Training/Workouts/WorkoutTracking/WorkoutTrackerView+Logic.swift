//
//  WorkoutTrackerView+Logic.swift
//  DialedIn
//
//  Extracted non-UI logic from WorkoutTrackerView to reduce file length.
//

import SwiftUI
import HealthKit

extension WorkoutTrackerView {
    // MARK: - Computed Properties
    
    var elapsedTimeString: String {
        let elapsed = Date().timeIntervalSince(  startTime)
        let hours = Int(elapsed) / 3600
        let minutes = Int(elapsed) / 60 % 60
        let seconds = Int(elapsed) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var isRestActive: Bool {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        guard let end = hkWorkoutManager.restEndTime else { return false }
        return Date() < end
        #else
        return false
        #endif
    }
    
    var completedSetsCount: Int {
        workoutSession.exercises.flatMap { $0.sets }.filter { $0.completedAt != nil }.count
    }
    
    var totalSetsCount: Int {
        workoutSession.exercises.flatMap { $0.sets }.count
    }
    
    var formattedVolume: String {
        let totalVolume = computeTotalVolumeKg()
        return String(format: "%.0f kg", totalVolume)
    }

    private func onNotesPressed() {
        showingWorkoutNotes = true
    }

    internal func buildView() {
        // Refresh from local active session to ensure persisted edits are loaded
        if let latest = try? workoutSessionManager.getLocalWorkoutSession(id: workoutSession.id) {
            workoutSession = latest
            workoutNotes = latest.notes ?? ""
        } else if let activeOpt = try? workoutSessionManager.getActiveLocalWorkoutSession() {
            if activeOpt.id == workoutSession.id {
                workoutSession = activeOpt
                workoutNotes = activeOpt.notes ?? ""
            }
        }
        // Ensure start time comes from the session creation time
        startTime = workoutSession.dateCreated
        // Ensure current exercise points to the first incomplete item
        syncCurrentExerciseIndexToFirstIncomplete(in: workoutSession.exercises)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Ensure an existing Live Activity is reused, otherwise start one
        workoutActivityViewModel.ensureLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: hkWorkoutManager.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil
        )
        #endif

        // Expand first incomplete exercise by default (fallback to first if all complete)
        if let idx = firstIncompleteExerciseIndex(in: workoutSession.exercises) {
            expandedExerciseIds.insert(workoutSession.exercises[idx].id)
        } else if let firstExercise = workoutSession.exercises.first {
            expandedExerciseIds.insert(firstExercise.id)
        }
    }

    func discardWorkout() {
        Task {
            do {
                // Cancel any pending rest timer notifications
                await pushManager.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
                
                try workoutSessionManager.deleteLocalWorkoutSession(id: workoutSession.id)
                // Don't mark scheduled workout as complete when discarding
                await workoutSessionManager.endActiveSession(markScheduledComplete: false)
                    dismiss()
            } catch {
                await MainActor.run {
                    showAlert = AnyAppAlert(
                        title: "Failed to discard workout",
                        subtitle: error.localizedDescription
                    )
                }
            }
        }
    }

    private func computeTotalVolumeKg() -> Double {
        workoutSession.exercises.flatMap { $0.sets }
            .compactMap { set in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            .reduce(0.0, +)
    }
    
    private func progressWidth(geometryWidth: CGFloat) -> CGFloat {
        guard totalSetsCount > 0 else { return 0 }
        let progress = Double(completedSetsCount) / Double(totalSetsCount)
        return geometryWidth * progress
    }
    
    private var isCurrentExerciseCompleted: Bool {
        guard currentExerciseIndex < workoutSession.exercises.count else { return false }
        let currentExercise = workoutSession.exercises[currentExerciseIndex]
        return areAllSetsCompleted(in: currentExercise.id)
    }
    
    private func pauseResumeWorkout() {
        isActive.toggle()
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        hkWorkoutManager.togglePause()
        // Update activity immediately when toggling pause/resume
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: hkWorkoutManager.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
    
    // MARK: - Exercise Management
    
    private func toggleExerciseExpansion(_ exerciseId: String) {
        if expandedExerciseIds.contains(exerciseId) {
            expandedExerciseIds.remove(exerciseId)
        } else {
            expandedExerciseIds.insert(exerciseId)
        }
    }
    
    private func moveToNextExercise() {
        if currentExerciseIndex < workoutSession.exercises.count - 1 {
            currentExerciseIndex += 1
            // Auto-expand next exercise
            let nextExercise = workoutSession.exercises[currentExerciseIndex]
            expandedExerciseIds.insert(nextExercise.id)
            
            // Optionally collapse the previous exercise
            if currentExerciseIndex > 0 {
                let previousExercise = workoutSession.exercises[currentExerciseIndex - 1]
                expandedExerciseIds.remove(previousExercise.id)
            }
        }
    }
    
    private func areAllSetsCompleted(in exerciseId: String) -> Bool {
        guard let exercise = workoutSession.exercises.first(where: { $0.id == exerciseId }) else {
            return false
        }
        
        // Return true if all sets are completed (and there's at least one set)
        return !exercise.sets.isEmpty && exercise.sets.allSatisfy { $0.completedAt != nil }
    }
    
    // MARK: - Set Management
    
    internal func updateSet(_ updatedSet: WorkoutSetModel, in exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }),
              let setIndex = workoutSession.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == updatedSet.id }) else {
            return
        }
        // Track completion transition (exercise-level)
        let exerciseBefore = workoutSession.exercises[exerciseIndex]
        let wasExerciseCompleteBefore = !exerciseBefore.sets.isEmpty && exerciseBefore.sets.allSatisfy { $0.completedAt != nil }

        var updatedExercises = workoutSession.exercises
        let previousCompletedAt = updatedExercises[exerciseIndex].sets[setIndex].completedAt
        updatedExercises[exerciseIndex].sets[setIndex] = updatedSet
        let isExerciseCompleteNow = !updatedExercises[exerciseIndex].sets.isEmpty && updatedExercises[exerciseIndex].sets.allSatisfy { $0.completedAt != nil }
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()
        
        // Start a rest timer when a set transitions from incomplete -> complete
        if previousCompletedAt == nil, updatedSet.completedAt != nil {
            // Use rest defined for this set (applies after this set)
            let customForThisSet = restBeforeSetIdToSec[updatedSet.id]
            startRestTimer(durationSeconds: customForThisSet ?? restDurationSeconds)
        }
        
        // If this change completed the last set of the exercise, collapse it and expand the next
        if !wasExerciseCompleteBefore && isExerciseCompleteNow {
            let nextIndex = exerciseIndex + 1
            if nextIndex < updatedExercises.count {
                expandedExerciseIds.removeAll()
                expandedExerciseIds.insert(updatedExercises[nextIndex].id)
                currentExerciseIndex = nextIndex
            } else {
                // No next exercise; just collapse the completed one
                expandedExerciseIds.remove(updatedExercises[exerciseIndex].id)
            }
        }
        
        // Always align current exercise to top-most incomplete after updates
        syncCurrentExerciseIndexToFirstIncomplete(in: workoutSession.exercises)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Update activity to reflect set/volume/progress changes
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: hkWorkoutManager.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
    
    internal func addSet(to exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }),
              let userId = userManager.currentUser?.userId else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
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
            completedAt: nil,
            dateCreated: Date()
        )
        
        updatedExercises[exerciseIndex].sets.append(newSet)
        // Seed new set's rest with last known value
        if let last = lastKnownRestForExercise(exerciseIndex: exerciseIndex) {
            restBeforeSetIdToSec[newSet.id] = last
        }
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()
        // Realign current exercise in case previously all-complete edge cases shift
        syncCurrentExerciseIndexToFirstIncomplete(in: workoutSession.exercises)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: hkWorkoutManager.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
    
    internal func deleteSet(_ setId: String, from exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].sets.removeAll { $0.id == setId }
        // Remove any rest mapping for this set
        restBeforeSetIdToSec.removeValue(forKey: setId)
        
        // Reindex remaining sets
        for index in updatedExercises[exerciseIndex].sets.indices {
            updatedExercises[exerciseIndex].sets[index].index = index + 1
        }
        
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()
        // Realign current exercise after deletion
        syncCurrentExerciseIndexToFirstIncomplete(in: workoutSession.exercises)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: hkWorkoutManager.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
    
    // MARK: - Data Persistence
    
    private func saveWorkoutProgress() {
        Task {
            do {
                try workoutSessionManager.updateLocalWorkoutSession(session: workoutSession)
                // Keep active session storage in sync so minimize/restore loads latest edits
                try? workoutSessionManager.setActiveLocalWorkoutSession(workoutSession)
                await MainActor.run {
                    workoutSessionManager.activeSession = workoutSession
                }
            } catch {
                    showAlert = AnyAppAlert(title: "Failed to save progress", subtitle: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Rest Timer Controls
    
    private func startRestTimer(durationSeconds: Int = 0) {
        let duration = durationSeconds > 0 ? durationSeconds : restDurationSeconds
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        hkWorkoutManager.startRest(durationSeconds: duration, session: workoutSession, currentExerciseIndex: currentExerciseIndex)
        // Sync rest timer with manager for tab bar accessory
        workoutSessionManager.restEndTime = hkWorkoutManager.restEndTime

        // Schedule local notification for when rest is complete
        if let endTime = hkWorkoutManager.restEndTime {
            Task {
                do {
                    try await pushManager.schedulePushNotification(
                        identifier: restTimerNotificationId,
                        title: "Rest Complete",
                        body: "Time to get back to your workout!",
                        date: endTime
                    )
                } catch {
                    // Silently fail - notification is nice to have but not critical
                    print("Failed to schedule rest timer notification: \(error)")
                }
            }
        }
        #endif
    }
    
    private func cancelRestTimer() {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Cancel in manager (will also update Live Activity)
        hkWorkoutManager.cancelRest()
        #endif
        
        // Sync rest timer with manager for tab bar accessory
        workoutSessionManager.restEndTime = nil
        
        // Cancel the pending rest timer notification
        Task {
            await pushManager.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
        }
    }
    
    internal func updateWorkoutNotes() {
        workoutSession.notes = workoutNotes.isEmpty ? nil : workoutNotes
        saveWorkoutProgress()
    }
    
    internal func updateExerciseNotes(_ notes: String, for exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].notes = notes.isEmpty ? nil : notes
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()
    }
    
    private func createExerciseHistoryEntries(performedAt: Date) async throws {
        guard let userId = userManager.currentUser?.userId else {
            throw NSError(domain: "WorkoutTrackerView", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Create exercise history entries for each exercise in the session
        for workoutExercise in workoutSession.exercises {
            let historyEntry = ExerciseHistoryEntryModel.newEntry(
                authorId: userId,
                templateId: workoutExercise.templateId,
                templateName: workoutExercise.name,
                workoutSessionId: workoutSession.id,
                workoutExerciseId: workoutExercise.id,
                performedAt: performedAt,
                notes: workoutExercise.notes,
                sets: workoutExercise.sets
            )
            
            // Save to local storage
            try exerciseHistoryManager.addLocalExerciseHistory(entry: historyEntry)
            
            // Save to remote storage
            try await exerciseHistoryManager.createExerciseHistory(entry: historyEntry)
        }
    }
    
    internal func finishWorkout() {
        Task {
            do {
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                // End HK session first
                hkWorkoutManager.endWorkout()
                #endif
                
                let endTime = Date()
                
                // Cancel any pending rest timer notifications
                await pushManager.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
                
                // Update session end time
                workoutSession.endSession(at: endTime)
                try workoutSessionManager.endLocalWorkoutSession(id: workoutSession.id, at: endTime)
                
                // Save to remote
                try await workoutSessionManager.createWorkoutSession(session: workoutSession)
                try await workoutSessionManager.endWorkoutSession(id: workoutSession.id, at: endTime)
                
                // Create exercise history entries (remote + local)
                try await createExerciseHistoryEntries(performedAt: endTime)
                
                    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                    workoutActivityViewModel.endLiveActivity(session: workoutSession, success: true)
                    #endif
                await workoutSessionManager.endActiveSession()
                    dismiss()
            } catch {
                showAlert = AnyAppAlert(title: "Failed to finish workout", subtitle: error.localizedDescription)
            }
        }
    }
    
    private func saveAndExit() {
        Task {
            do {
                try workoutSessionManager.updateLocalWorkoutSession(session: workoutSession)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                showAlert = AnyAppAlert(title: "Failed to save workout", subtitle: error.localizedDescription)
            }
        }
    }

    internal func addSelectedExercises() {
        guard !pendingSelectedTemplates.isEmpty, let userId = userManager.currentUser?.userId else { return }
        var updated = workoutSession.exercises
        let startIndex = updated.count
        for (offset, template) in pendingSelectedTemplates.enumerated() {
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
        workoutSession.updateExercises(updated)
        // Focus to first incomplete (likely the first newly added)
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)
        // Expand the current exercise
        if currentExerciseIndex < updated.count {
            expandedExerciseIds.removeAll()
            expandedExerciseIds.insert(updated[currentExerciseIndex].id)
        }
        saveWorkoutProgress()

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: hkWorkoutManager.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }

    @ToolbarContentBuilder
    internal var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                // Minimize instead of ending the session
                workoutSessionManager.minimizeActiveSession()
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
        ToolbarSpacer(.fixed, placement: .topBarLeading)
        ToolbarItem(placement: .topBarLeading) {
            Button(role: .destructive) {
                showAlert = AnyAppAlert(title: "End Workout?", subtitle: "Are you sure you want to discard this workout?") {
                    AnyView(
                        VStack {
                            Button("Cancel", role: .cancel) {
                                showAlert = nil
                            }
                            Button("Discard", role: .destructive) {
                                discardWorkout()
                            }

                        }
                    )
                }
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                onNotesPressed()
            } label: {
                Image(systemName: "long.text.page.and.pencil")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                finishWorkout()
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
        }
        
        ToolbarItem(placement: .bottomBar) {
            Button {
                if isRestActive {
                    cancelRestTimer()
                } else {
                    startRestTimer()
                }
            } label: {
                Image(systemName: isRestActive ? "stop" : "timer")
                    .foregroundColor(isRestActive ? .red : .accent)
            }
        }
        
        ToolbarSpacer(.flexible, placement: .bottomBar)
        
        ToolbarItem(placement: .bottomBar) {
            Button {
                pendingSelectedTemplates = []
                showingAddExercise = true
            } label: {
                Image(systemName: "plus")
            }
        }
        
    }

    internal func moveExercises(from source: IndexSet, to destination: Int) {
        var updated = workoutSession.exercises
        updated.move(fromOffsets: source, toOffset: destination)

        applyReorderedExercises(updated, movedFrom: source.first, movedTo: destination)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: hkWorkoutManager.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }

    internal func reorderExercises(from sourceIndex: Int, to targetIndex: Int) {
        guard sourceIndex != targetIndex else { return }
        var updated = workoutSession.exercises
        let element = updated.remove(at: sourceIndex)
        updated.insert(element, at: targetIndex)
        applyReorderedExercises(updated, movedFrom: sourceIndex, movedTo: targetIndex)
    }

    private func applyReorderedExercises(_ updated: [WorkoutExerciseModel], movedFrom: Int?, movedTo: Int) {
        var updated = updated
        // Reindex exercises only (do not touch set indices)
        for idx in updated.indices {
            updated[idx].index = idx + 1
        }

        // Always align current exercise to top-most incomplete after reorders
        workoutSession.updateExercises(updated)
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)

        saveWorkoutProgress()
    }

    internal func deleteExercise(_ exerciseId: String) {
        var updated = workoutSession.exercises
        guard let idx = updated.firstIndex(where: { $0.id == exerciseId }) else { return }
        updated.remove(at: idx)
        // Reindex remaining exercises
        for index in updated.indices { updated[index].index = index + 1 }
        workoutSession.updateExercises(updated)
        // Keep expansion state tidy
        expandedExerciseIds.remove(exerciseId)
        // Realign current exercise
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)
        saveWorkoutProgress()

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: hkWorkoutManager.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }

    private func firstIncompleteExerciseIndex(in exercises: [WorkoutExerciseModel]) -> Int? {
        exercises.firstIndex(where: { !$0.sets.isEmpty && !$0.sets.allSatisfy { $0.completedAt != nil } })
    }

    private func syncCurrentExerciseIndexToFirstIncomplete(in exercises: [WorkoutExerciseModel]) {
        if let idx = firstIncompleteExerciseIndex(in: exercises) {
            currentExerciseIndex = idx
        } else {
            currentExerciseIndex = max(0, exercises.isEmpty ? 0 : exercises.count - 1)
        }
    }

    // Determine next set's rest seconds from per-set map
    private func nextSetRestSeconds(exerciseIndex: Int, setIndex: Int) -> Int? {
        guard exerciseIndex < workoutSession.exercises.count else { return nil }
        let sets = workoutSession.exercises[exerciseIndex].sets
        let nextIndex = setIndex + 1
        guard nextIndex < sets.count else { return nil }
        let nextSet = sets[nextIndex]
        return restBeforeSetIdToSec[nextSet.id]
    }

    private func lastKnownRestForExercise(exerciseIndex: Int) -> Int? {
        guard exerciseIndex < workoutSession.exercises.count else { return nil }
        let sets = workoutSession.exercises[exerciseIndex].sets
        // Walk from last to first to find a mapping
        for set in sets.reversed() {
            if let val = restBeforeSetIdToSec[set.id] { return val }
        }
        return nil
    }
}

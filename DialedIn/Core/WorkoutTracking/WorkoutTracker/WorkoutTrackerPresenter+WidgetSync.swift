//
//  WorkoutTrackerPresenter+WidgetSync.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import Foundation

// MARK: - Widget Sync
extension WorkoutTrackerPresenter {
    func startWidgetSyncTimer() {
        widgetSyncTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.syncPendingSetCompletionFromWidget()
                self?.syncPendingWorkoutCompletionFromWidget()
            }
        }
    }
    
    func stopWidgetSyncTimer() {
        widgetSyncTimer?.invalidate()
        widgetSyncTimer = nil
    }
    
    func syncPendingSetCompletionFromWidget() {
        guard let pending = SharedWorkoutStorage.pendingSetCompletion,
              let workoutSession else { return }
        print("🔍 Widget Completion: Found pending for set '\(pending.setId)'")
        print("   Values: weight=\(pending.weightKg ?? 0)kg, reps=\(pending.reps ?? 0)")
        
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { exercise in
            exercise.sets.contains { $0.id == pending.setId }
        }) else {
            print("❌ Widget Completion: Set not found in current workout")
            print("   Available set IDs: \(workoutSession.exercises.flatMap { $0.sets.map { $0.id } })")
            SharedWorkoutStorage.clearPendingSetCompletion()
            return
        }
        
        guard let setIndex = workoutSession.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == pending.setId }) else {
            print("❌ Set ID matched but not found in sets array")
            SharedWorkoutStorage.clearPendingSetCompletion()
            return
        }
        
        let exercise = workoutSession.exercises[exerciseIndex]
        print("✓ Found in exercise \(exerciseIndex): '\(exercise.name)' at set index \(setIndex)")
        
        var updatedSet = exercise.sets[setIndex]
        
        let beforeComplete = updatedSet.completedAt
        print("   Before: completedAt=\(beforeComplete?.description ?? "nil")")
        
        if let weight = pending.weightKg { updatedSet.weightKg = weight }
        if let reps = pending.reps { updatedSet.reps = reps }
        if let distance = pending.distanceMeters { updatedSet.distanceMeters = distance }
        if let duration = pending.durationSec { updatedSet.durationSec = duration }
        updatedSet.completedAt = pending.completedAt
        
        print("   After: completedAt=\(updatedSet.completedAt?.description ?? "nil")")
        
        SharedWorkoutStorage.clearPendingSetCompletion()
        
        print("✅ Widget Completion: Routing through updateSet() to trigger all mechanics")
        
        updateSet(updatedSet, in: exercise.id)
    }
    
    func syncPendingWorkoutCompletionFromWidget() {
        guard let pending = SharedWorkoutStorage.pendingWorkoutCompletion,
              let workoutSession else { return }

        print("🔍 Widget Workout Completion: Found pending for session '\(pending.sessionId)'")
        
        guard pending.sessionId == workoutSession.id else {
            print("❌ Widget Workout Completion: Session ID mismatch")
            SharedWorkoutStorage.clearPendingWorkoutCompletion()
            return
        }
        
        print("✅ Widget Workout Completion: Triggering finishWorkout()")
        
        SharedWorkoutStorage.clearPendingWorkoutCompletion()
    }
}

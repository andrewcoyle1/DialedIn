//
//  WorkoutTrackerView+WidgetSync.swift
//  DialedIn
//
//  Extracted widget sync logic from WorkoutTrackerView+Logic to reduce file length.
//

import Foundation

extension WorkoutTrackerView {
    // MARK: - Widget Communication
    
    func startWidgetSyncTimer() {
        // Poll for widget set completions and workout completion every second
        widgetSyncTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            syncPendingSetCompletionFromWidget()
            syncPendingWorkoutCompletionFromWidget()
        }
    }
    
    func stopWidgetSyncTimer() {
        widgetSyncTimer?.invalidate()
        widgetSyncTimer = nil
    }
    
    func syncPendingSetCompletionFromWidget() {
        // Check if widget completed a set
        guard let pending = SharedWorkoutStorage.pendingSetCompletion else { return }
        
        print("🔍 Widget Completion: Found pending for set '\(pending.setId)'")
        print("   Values: weight=\(pending.weightKg ?? 0)kg, reps=\(pending.reps ?? 0)")
        
        // Find the set in the current workout
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
        
        // Get the set and apply values from widget
        var updatedSet = exercise.sets[setIndex]
        
        let beforeComplete = updatedSet.completedAt
        print("   Before: completedAt=\(beforeComplete?.description ?? "nil")")
        
        // Apply values from widget completion (these are already in SI units)
        if let weight = pending.weightKg { updatedSet.weightKg = weight }
        if let reps = pending.reps { updatedSet.reps = reps }
        if let distance = pending.distanceMeters { updatedSet.distanceMeters = distance }
        if let duration = pending.durationSec { updatedSet.durationSec = duration }
        updatedSet.completedAt = pending.completedAt
        
        print("   After: completedAt=\(updatedSet.completedAt?.description ?? "nil")")
        
        // Clear the pending completion BEFORE calling updateSet to avoid reprocessing
        SharedWorkoutStorage.clearPendingSetCompletion()
        
        print("✅ Widget Completion: Routing through updateSet() to trigger all mechanics")
        
        // Route through existing updateSet() logic to ensure mechanics
        updateSet(updatedSet, in: exercise.id)
    }
    
    func syncPendingWorkoutCompletionFromWidget() {
        // Check if widget requested workout completion
        guard let pending = SharedWorkoutStorage.pendingWorkoutCompletion else { return }
        
        print("🔍 Widget Workout Completion: Found pending for session '\(pending.sessionId)'")
        
        // Verify this is the current session
        guard pending.sessionId == workoutSession.id else {
            print("❌ Widget Workout Completion: Session ID mismatch")
            SharedWorkoutStorage.clearPendingWorkoutCompletion()
            return
        }
        
        print("✅ Widget Workout Completion: Triggering finishWorkout()")
        
        // Clear the pending completion BEFORE calling finishWorkout
        SharedWorkoutStorage.clearPendingWorkoutCompletion()
        
        // Call the existing finishWorkout method which handles all the proper save logic
        finishWorkout()
    }
}

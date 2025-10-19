//
//  WorkoutRestTimerIntents.swift
//  DialedIn
//
//  Created by AI Assistant on 17/10/2025.
//

import Foundation
import AppIntents
#if canImport(ActivityKit)
import ActivityKit
#endif

// MARK: - Adjust Rest Timer Intent

@available(iOS 16.0, *)
struct AdjustRestTimerIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Adjust Rest Timer"
    static let description: IntentDescription = "Adjust the workout rest timer by adding or subtracting time"
    
    @Parameter(title: "Adjustment (seconds)")
    var adjustment: Int
    
    init() {
        self.adjustment = 0
    }
    
    init(adjustment: Int) {
        self.adjustment = adjustment
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Find the active workout Live Activity
        guard let activity = Activity<WorkoutActivityAttributes>.activities.first else {
            print("⚠️ No active Live Activity found")
            return .result()
        }
        
        let state = activity.content.state
        
        // Get current rest end time
        guard let currentRestEnd = state.restEndsAt else {
            print("⚠️ No active rest timer")
            return .result()
        }
        
        // Set loading state immediately
        var loadingState = state
        loadingState.isProcessingIntent = true
        loadingState.lastIntentTimestamp = Date()
        
        await activity.update(
            ActivityContent(
                state: loadingState,
                staleDate: currentRestEnd,
                relevanceScore: 100
            )
        )
        
        // Calculate new rest end time
        let newRestEnd = currentRestEnd.addingTimeInterval(TimeInterval(adjustment))
        
        // Don't allow rest time to go negative (if adjusted time is in the past, set to now + 1 second)
        let finalRestEnd = newRestEnd > Date() ? newRestEnd : Date().addingTimeInterval(1)
        
        // Update shared storage so the main app knows about the change
        SharedWorkoutStorage.restEndTime = finalRestEnd
        
        // Create updated state with new rest end time and clear loading state
        var updatedState = state
        updatedState.restEndsAt = finalRestEnd
        updatedState.isProcessingIntent = false
        
        // Update the Live Activity
        await activity.update(
            ActivityContent(
                state: updatedState,
                staleDate: finalRestEnd,
                relevanceScore: 100
            )
        )
        
        print("✅ Rest timer adjusted by \(adjustment)s, new end time: \(finalRestEnd)")
        #endif
        
        return .result()
    }
}

// MARK: - Skip Rest Timer Intent

@available(iOS 16.0, *)
struct SkipRestTimerIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Skip Rest Timer"
    static let description: IntentDescription = "Skip the current rest timer and continue workout"
        
    @MainActor
    func perform() async throws -> some IntentResult {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Find the active workout Live Activity
        guard let activity = Activity<WorkoutActivityAttributes>.activities.first else {
            print("⚠️ No active Live Activity found")
            return .result()
        }
        
        let state = activity.content.state
        
        // Set loading state immediately
        var loadingState = state
        loadingState.isProcessingIntent = true
        loadingState.lastIntentTimestamp = Date()
        
        await activity.update(
            ActivityContent(
                state: loadingState,
                staleDate: state.restEndsAt,
                relevanceScore: 100
            )
        )
        
        // Clear shared storage so the main app knows the rest was skipped
        SharedWorkoutStorage.clearRestEndTime()
        
        // Create updated state with rest timer cleared and loading state cleared
        var updatedState = state
        updatedState.restEndsAt = nil
        updatedState.statusMessage = nil
        updatedState.isProcessingIntent = false
        
        // Update the Live Activity
        await activity.update(
            ActivityContent(
                state: updatedState,
                staleDate: nil,
                relevanceScore: 100
            )
        )
        
        print("✅ Rest timer skipped")
        #endif
        return .result()
    }
}

// MARK: - Complete Workout Intent

@available(iOS 16.0, *)
struct CompleteWorkoutIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Complete Workout"
    static let description: IntentDescription = "Finish and save the workout session"
    
    @MainActor
    func perform() async throws -> some IntentResult {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Find the active workout Live Activity
        guard let activity = Activity<WorkoutActivityAttributes>.activities.first else {
            print("⚠️ No active Live Activity found")
            return .result()
        }
        
        let state = activity.content.state
        let sessionId = activity.attributes.sessionId
        
        // Set loading state immediately
        var loadingState = state
        loadingState.isProcessingIntent = true
        loadingState.lastIntentTimestamp = Date()
        
        await activity.update(
            ActivityContent(
                state: loadingState,
                staleDate: state.restEndsAt,
                relevanceScore: 100
            )
        )
        
        // Create workout completion request and write to shared storage
        let completion = SharedWorkoutStorage.PendingWorkoutCompletion(
            sessionId: sessionId,
            completedAt: Date()
        )
        SharedWorkoutStorage.pendingWorkoutCompletion = completion
        
        print("✅ Workout completion requested for session '\(sessionId)'")
        
        // The main app will handle the actual workout completion and will end the Live Activity
        #endif
        return .result()
    }
}

// MARK: - Complete Set Intent

@available(iOS 16.0, *)
struct CompleteSetIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Complete Set"
    static let description: IntentDescription = "Mark the current set as complete and start rest"

    // Use a conservative default if the app isn't in the foreground to provide immediate feedback
    private let defaultRestDurationSeconds: Int = 90

    @MainActor
    func perform() async throws -> some IntentResult {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Find the active workout Live Activity
        guard let activity = Activity<WorkoutActivityAttributes>.activities.first else {
            print("⚠️ No active Live Activity found")
            return .result()
        }

        let state = activity.content.state
        
        // Only complete if we have a target set ID
        guard let setId = state.targetSetId else {
            print("⚠️ No target set to complete")
            return .result()
        }
        
        // Set loading state immediately
        var loadingState = state
        loadingState.isProcessingIntent = true
        loadingState.lastIntentTimestamp = Date()
        
        await activity.update(
            ActivityContent(
                state: loadingState,
                staleDate: state.restEndsAt,
                relevanceScore: 100
            )
        )
        
        // Use defer to ensure loading state is always cleared
        defer {
            Task { @MainActor in
                // Clear loading state after a brief delay to show feedback
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            }
        }
        
        // Create set completion with target values and write to shared storage
        let completion = SharedWorkoutStorage.PendingSetCompletion(
            setId: setId,
            weightKg: state.targetWeightKg,
            reps: state.targetReps,
            distanceMeters: state.targetDistanceMeters,
            durationSec: state.targetDurationSec,
            completedAt: Date()
        )
        SharedWorkoutStorage.pendingSetCompletion = completion

        // Read the current state and optimistically increment set count for instant UI feedback
        var updatedState = state
        let currentCompleted = updatedState.completedSetsCount
        let totalSets = max(updatedState.totalSetsCount, 0)
        if totalSets > 0 {
            updatedState.completedSetsCount = min(currentCompleted + 1, totalSets)
            // Update progress if available
            let progress = totalSets > 0 ? Double(updatedState.completedSetsCount) / Double(totalSets) : 0
            updatedState.progress = progress
        }
        
        // Check if this completes all sets in the workout
        let isAllSetsComplete = totalSets > 0 && updatedState.completedSetsCount >= totalSets
        updatedState.isAllSetsComplete = isAllSetsComplete

        // Only start a rest period if there are more sets to do
        if !isAllSetsComplete {
            let restEnd = Date().addingTimeInterval(TimeInterval(defaultRestDurationSeconds))
            updatedState.restEndsAt = restEnd
            updatedState.statusMessage = "Resting"
            // Persist rest timer to shared storage
            SharedWorkoutStorage.restEndTime = restEnd
        } else {
            // All sets complete - clear rest timer
            updatedState.restEndsAt = nil
            updatedState.statusMessage = nil
            SharedWorkoutStorage.clearRestEndTime()
        }
        
        // Clear loading state
        updatedState.isProcessingIntent = false

        // Push the update to the Live Activity
        await activity.update(
            ActivityContent(
                state: updatedState,
                staleDate: updatedState.restEndsAt,
                relevanceScore: 100
            )
        )

        if let restEnd = updatedState.restEndsAt {
            print("✅ Completed set '\(setId)' with values (weight: \(state.targetWeightKg ?? 0)kg, reps: \(state.targetReps ?? 0)), starting rest until: \(restEnd)")
        } else {
            print("✅ Completed set '\(setId)' - all sets complete, no rest timer started")
        }
        #endif
        return .result()
    }
}

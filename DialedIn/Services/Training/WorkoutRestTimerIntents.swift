//
//  WorkoutRestTimerIntents.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import Foundation
import AppIntents
#if canImport(ActivityKit)
@preconcurrency import ActivityKit
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
        
        await updateLoading(activity: activity, state: state)
        
        defer {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
        }
        
        SharedWorkoutStorage.pendingSetCompletion = buildPendingSetCompletion(from: state, setId: setId)

        var updatedState = applyOptimisticProgress(to: state)
        updatedState = applyRestLogic(to: updatedState)
        await pushUpdate(activity: activity, newState: updatedState)

        if let restEnd = updatedState.restEndsAt {
            print("✅ Completed set '\(setId)' with values (weight: \(state.targetWeightKg ?? 0)kg, reps: \(state.targetReps ?? 0)), starting rest until: \(restEnd)")
        } else {
            print("✅ Completed set '\(setId)' - all sets complete, no rest timer started")
        }
        #endif
        return .result()
    }
}

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
@MainActor
fileprivate extension CompleteSetIntent {

    func updateLoading(activity: Activity<WorkoutActivityAttributes>, state: WorkoutActivityAttributes.ContentState) async {
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
    }

    func buildPendingSetCompletion(from state: WorkoutActivityAttributes.ContentState, setId: String) -> SharedWorkoutStorage.PendingSetCompletion {
        SharedWorkoutStorage.PendingSetCompletion(
            setId: setId,
            weightKg: state.targetWeightKg,
            reps: state.targetReps,
            distanceMeters: state.targetDistanceMeters,
            durationSec: state.targetDurationSec,
            completedAt: Date()
        )
    }

    func applyOptimisticProgress(to state: WorkoutActivityAttributes.ContentState) -> WorkoutActivityAttributes.ContentState {
        var updated = state
        let currentCompleted = updated.completedSetsCount
        let totalSets = max(updated.totalSetsCount, 0)
        if totalSets > 0 {
            updated.completedSetsCount = min(currentCompleted + 1, totalSets)
            updated.progress = totalSets > 0 ? Double(updated.completedSetsCount) / Double(totalSets) : 0
        }
        updated.isAllSetsComplete = totalSets > 0 && updated.completedSetsCount >= totalSets
        return updated
    }

    func applyRestLogic(to state: WorkoutActivityAttributes.ContentState) -> WorkoutActivityAttributes.ContentState {
        var updated = state
        if !updated.isAllSetsComplete {
            let restEnd = Date().addingTimeInterval(TimeInterval(defaultRestDurationSeconds))
            updated.restEndsAt = restEnd
            updated.statusMessage = "Resting"
            SharedWorkoutStorage.restEndTime = restEnd
        } else {
            updated.restEndsAt = nil
            updated.statusMessage = nil
            SharedWorkoutStorage.clearRestEndTime()
        }
        updated.isProcessingIntent = false
        return updated
    }

    func pushUpdate(activity: Activity<WorkoutActivityAttributes>, newState: WorkoutActivityAttributes.ContentState) async {
        await activity.update(
            ActivityContent(
                state: newState,
                staleDate: newState.restEndsAt,
                relevanceScore: 100
            )
        )
    }
}
#endif

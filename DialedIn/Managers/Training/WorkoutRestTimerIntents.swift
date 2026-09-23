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
            return .result()
        }
        
        let state = activity.content.state
        
        // Get current rest end time
        guard let currentRestEnd = state.restEndsAt else {
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

        await LiveActivityIntentHandler.current?.adjustRest(by: adjustment)
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

        await LiveActivityIntentHandler.current?.skipRest()
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
        
        // The handler ends HealthKit, the session and the activity, as Finish does in the app.
        await LiveActivityIntentHandler.current?.completeWorkout()
        #endif
        return .result()
    }
}

// MARK: - Complete Set Intent

@available(iOS 16.0, *)
struct CompleteSetIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Complete Set"
    static let description: IntentDescription = "Mark the current set as complete and start rest"

    @MainActor
    func perform() async throws -> some IntentResult {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Find the active workout Live Activity
        guard let activity = Activity<WorkoutActivityAttributes>.activities.first else {
            return .result()
        }

        let state = activity.content.state
        
        // Only complete if we have a target set ID
        guard let setId = state.targetSetId else {
            return .result()
        }
        
        await updateLoading(activity: activity, state: state)

        var updatedState = applyLoggedSet(to: state, setId: setId)
        updatedState = applyOptimisticProgress(to: updatedState)
        updatedState.isProcessingIntent = false
        await pushUpdate(activity: activity, newState: updatedState)

        // The handler logs the set, starts the real rest and pushes the saved session, which is
        // what puts a countdown on screen. Awaited, so `perform()` does not return before the app
        // has actually done the work the button promised.
        await LiveActivityIntentHandler.current?.completeSet(id: setId)
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

    /// Record the set just logged, so the rest that follows can offer the rep correction (spec §4).
    /// The target fields are still the ones that were on screen when the button was pressed.
    func applyLoggedSet(to state: WorkoutActivityAttributes.ContentState, setId: String) -> WorkoutActivityAttributes.ContentState {
        var updated = state
        updated.lastLoggedSetId = setId
        updated.lastLoggedReps = state.targetReps
        updated.lastLoggedWeightKg = state.targetWeightKg
        return updated
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

// MARK: - Adjust Last Set Reps Intent

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)

/// The whole decision behind `AdjustLastSetRepsIntent`, with nothing that needs a live
/// `Activity` to exercise (spec §4).
///
/// The correction window is open only while the rest that followed a logged set is still
/// running; outside it there is no set to correct and the tap does nothing.
enum AdjustLastSetRepsDecision {

    /// The reps the logged set should now carry, or `nil` when the tap is a no-op.
    static func adjustedReps(
        state: WorkoutActivityAttributes.ContentState,
        now: Date,
        delta: Int
    ) -> Int? {
        guard state.lastLoggedSetId != nil else { return nil }
        guard let restEndsAt = state.restEndsAt, restEndsAt > now else { return nil }

        let base = state.lastLoggedReps ?? 0
        return min(max(base + delta, 0), 99)
    }
}

#endif

/// Correct the reps of the set that was just logged, during the rest that follows it.
///
/// `CompleteSetIntent` logs the prescribed reps, so a set that fell short would otherwise be
/// recorded as a hit and feed smart progression a number the user never lifted.
@available(iOS 16.0, *)
struct AdjustLastSetRepsIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Adjust Last Set Reps"
    static let description: IntentDescription = IntentDescription("Correct the reps of the set that was just logged")

    @Parameter(title: "Adjustment (reps)")
    var delta: Int

    init() {
        self.delta = 0
    }

    init(delta: Int) {
        self.delta = delta
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        guard let activity = Activity<WorkoutActivityAttributes>.activities.first else {
            return .result()
        }

        let state = activity.content.state

        guard let setId = state.lastLoggedSetId,
              let reps = AdjustLastSetRepsDecision.adjustedReps(state: state, now: Date(), delta: delta) else {
            return .result()
        }

        // Optimistic, so the label changes under the thumb rather than on the app's next tick.
        var updatedState = state
        updatedState.lastLoggedReps = reps
        updatedState.isProcessingIntent = false
        updatedState.lastIntentTimestamp = Date()

        await activity.update(
            ActivityContent(
                state: updatedState,
                staleDate: state.restEndsAt,
                relevanceScore: 100
            )
        )

        // The delta, not the clamped total: the handler clamps against the set's own reps, which
        // is the number that will be saved.
        await LiveActivityIntentHandler.current?.adjustLastSetReps(id: setId, delta: delta)
        #endif
        return .result()
    }
}

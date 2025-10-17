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
        
        // Get current rest end time
        guard let currentRestEnd = activity.content.state.restEndsAt else {
            print("⚠️ No active rest timer")
            return .result()
        }
        
        // Calculate new rest end time
        let newRestEnd = currentRestEnd.addingTimeInterval(TimeInterval(adjustment))
        
        // Don't allow rest time to go negative (if adjusted time is in the past, set to now + 1 second)
        let finalRestEnd = newRestEnd > Date() ? newRestEnd : Date().addingTimeInterval(1)
        
        // Update shared storage so the main app knows about the change
        SharedWorkoutStorage.restEndTime = finalRestEnd
        
        // Create updated state with new rest end time
        var updatedState = activity.content.state
        updatedState.restEndsAt = finalRestEnd
        
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
        
        // Clear shared storage so the main app knows the rest was skipped
        SharedWorkoutStorage.clearRestEndTime()
        
        // Create updated state with rest timer cleared
        var updatedState = activity.content.state
        updatedState.restEndsAt = nil
        updatedState.statusMessage = nil
        
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

        // Read the current state and optimistically increment set count for instant UI feedback
        var updatedState = activity.content.state
        let currentCompleted = updatedState.completedSetsCount
        let totalSets = max(updatedState.totalSetsCount, 0)
        if totalSets > 0 {
            updatedState.completedSetsCount = min(currentCompleted + 1, totalSets)
            // Update progress if available
            let progress = totalSets > 0 ? Double(updatedState.completedSetsCount) / Double(totalSets) : 0
            updatedState.progress = progress
        }

        // Start a rest period immediately for user feedback
        let restEnd = Date().addingTimeInterval(TimeInterval(defaultRestDurationSeconds))
        updatedState.restEndsAt = restEnd
        updatedState.statusMessage = "Resting"

        // Persist to shared storage so the main app can synchronize its model
        SharedWorkoutStorage.restEndTime = restEnd

        // Push the update to the Live Activity
        await activity.update(
            ActivityContent(
                state: updatedState,
                staleDate: restEnd,
                relevanceScore: 100
            )
        )

        print("✅ Completed set (optimistic), starting rest until: \(restEnd)")
        #endif
        return .result()
    }
}

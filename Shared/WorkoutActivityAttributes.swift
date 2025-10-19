//
//  WorkoutActivityAttributes.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/09/2025.
//

import Foundation
#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
import ActivityKit

struct WorkoutActivityAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {
        // Whether the workout timer is actively running (not paused)
        var isActive: Bool
        // Overall set progress across all exercises
        var completedSetsCount: Int
        var totalSetsCount: Int
        // Current exercise context
        var currentExerciseName: String?
        var currentExerciseImageName: String?
        var currentExerciseIndex: Int
        var totalExercisesCount: Int
        // Per-exercise set counts for more contextual display
        var currentExerciseCompletedSetsCount: Int
        var currentExerciseTotalSetsCount: Int
        // Current set target values (for widget display and completion)
        var targetSetId: String?
        var targetWeightKg: Double?
        var targetReps: Int?
        var targetDistanceMeters: Double?
        var targetDurationSec: Int?
        // If resting, the time when the rest period ends
        var restEndsAt: Date?
        // Optional status message to display (e.g. "Resting", "Get Ready")
        var statusMessage: String?
        // Optional running total of volume lifted in kilograms
        var totalVolumeKg: Double?
        // Convenience progress value 0.0...1.0 (completedSets/totalSets)
        var progress: Double
        // Workout ended state
        var isWorkoutEnded: Bool
        var endedSuccessfully: Bool?
        // Final summary metrics (populated when workout ends successfully)
        var finalDurationSeconds: TimeInterval?
        var finalVolumeKg: Double?
        var finalCompletedSetsCount: Int?
        var finalTotalExercisesCount: Int?
        // Button loading state
        var isProcessingIntent: Bool
        var lastIntentTimestamp: Date?
        // Workout completion state
        var isAllSetsComplete: Bool
    }

    // Immutable attributes for this workout Live Activity instance
    var sessionId: String
    var workoutName: String
    var startedAt: Date
    var workoutTemplateId: String?
}
#endif

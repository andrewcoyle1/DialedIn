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
        // Per-exercise set counts, within the group the target set belongs to: warm-ups while a
        // warm-up is next, working sets after that. "Warmup 1 of 2", then "Set 1 of 4".
        var currentExerciseCompletedSetsCount: Int
        var currentExerciseTotalSetsCount: Int
        var targetIsWarmup: Bool = false
        // Current set target values (for widget display and completion)
        var targetSetId: String?
        var targetWeightKg: Double?
        var targetReps: Int?
        var targetDistanceMeters: Double?
        var targetDurationSec: Int?
        // If resting, the time when the rest period ends
        var restEndsAt: Date?
        // Convenience progress value 0.0...1.0 (completedSets/totalSets)
        var progress: Double
        // Workout ended state
        var isWorkoutEnded: Bool
        // Final summary metrics (populated when workout ends successfully)
        var finalDurationSeconds: TimeInterval?
        var finalVolumeKg: Double?
        var finalCompletedSetsCount: Int?
        // Button loading state
        var isProcessingIntent: Bool
        // Workout completion state
        var isAllSetsComplete: Bool
        // The set most recently logged, whose reps can be corrected during the rest that follows
        var lastLoggedSetId: String?
        var lastLoggedReps: Int?
        var lastLoggedWeightKg: Double?
        // The exercise that follows the current one, and the target its first working set carries.
        // Populated so the `.exerciseDone` phase can name what is coming without the widget
        // reaching back into the session.
        var nextExerciseName: String?
        var nextExerciseFirstTargetWeightKg: Double?
        var nextExerciseFirstTargetReps: Int?
        var nextExerciseFirstTargetDistanceMeters: Double?
        var nextExerciseFirstTargetDurationSec: Int?
    }

    // Immutable attributes for this workout Live Activity instance
    var sessionId: String
    var workoutName: String
}
#endif

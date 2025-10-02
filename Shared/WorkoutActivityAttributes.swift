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
        var currentExerciseIndex: Int
        var totalExercisesCount: Int
        // If resting, the time when the rest period ends
        var restEndsAt: Date?
        // Optional status message to display (e.g. "Resting", "Get Ready")
        var statusMessage: String?
        // Optional running total of volume lifted in kilograms
        var totalVolumeKg: Double?
        // Convenience progress value 0.0...1.0 (completedSets/totalSets)
        var progress: Double
    }

    // Immutable attributes for this workout Live Activity instance
    var sessionId: String
    var workoutName: String
    var startedAt: Date
    var workoutTemplateId: String?
}
#endif

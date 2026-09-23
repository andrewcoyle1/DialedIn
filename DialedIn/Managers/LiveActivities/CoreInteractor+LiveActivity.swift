//
//  CoreInteractor+LiveActivity.swift
//  DialedIn
//
//  The Live Activity surface `CoreInteractor` exposes to the screens.
//
//  Split out of `LiveActivityManager.swift`, which had grown past the 750-line file limit.
//

import Foundation

extension CoreInteractor {
    // MARK: LiveActivityManager
    
    /// Ensure a Workout Live Activity using data from the given session
    /// - Parameters:
    ///   - session: The workout session used to seed immutable attributes
    ///   - isActive: Whether the workout timer is running
    ///   - currentExerciseIndex: Index of the currently focused exercise in the session
    ///   - restEndsAt: Optional rest countdown end time
    ///   - statusMessage: Optional status string (e.g. "Resting", "Ready")
    func ensureLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool = true,
        currentExerciseIndex: Int = 0,
        restEndsAt: Date? = nil,
        statusMessage: String? = nil
    ) {
        liveActivityManager.ensureLiveActivity(session: session, isActive: isActive, currentExerciseIndex: currentExerciseIndex, restEndsAt: restEndsAt, statusMessage: statusMessage)
    }
    
    /// Ensure a Workout Live Activity using data from the given session
    /// - Parameters:
    ///   - session: The workout session used to seed immutable attributes
    ///   - session: WorkoutSessionModel
    ///   - isActive: Bool
    ///   - currentExerciseIndex: Int
    ///   - restEndsAt: Date?
    ///   - statusMessage: String?
    ///   - totalVolumeKg: Double?
    ///   - elapsedTime: TimeInterval?
    func updateLiveActivity(params: LiveActivityUpdateParams) {
        liveActivityManager.updateLiveActivity(params: params)
    }
    
    /// Ensure a Workout Live Activity using data from the given session
    /// - Parameters:
    ///   - session: WorkoutSessionModel
    ///   - isCompleted: Bool
    ///   - statusMessage: String?
    func endLiveActivity(
        session: WorkoutSessionModel,
        isCompleted: Bool = true,
        statusMessage: String? = nil
    ) {
        liveActivityManager.endLiveActivity(session: session, isCompleted: isCompleted, statusMessage: statusMessage)
    }
}

//
//  CoreInteractor+LiveActivity.swift
//  DialedIn
//
//  The Live Activity surface `CoreInteractor` exposes to the screens.
//
//  Split out of `LiveActivityManager.swift`, which had grown past the 750-line file limit.
//

import Foundation
#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
import ActivityKit
#endif

extension CoreInteractor {
    // MARK: LiveActivityManager
    
    var liveActivityViewState: ActivityViewState? {
        liveActivityManager.activityViewState
    }
    
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
    
    /// Discard the currently active Live Activity
    func discardLiveActivity() async {
        await liveActivityManager.discardLiveActivity()
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
    
    /// End the live activity using a final content state and dismissal policy
    /// - Parameters:
    ///   - finalState: WorkoutActivityAttributes.ContentState
    ///   - dismissalPolicy: ActivityUIDismissalPolicy
    func endActivity(with finalState: WorkoutActivityAttributes.ContentState, dismissalPolicy: ActivityUIDismissalPolicy) async {
        await liveActivityManager.endActivity(with: finalState, dismissalPolicy: dismissalPolicy)
    }
    
    /// Update only isActive/rest/status from current content state to avoid recomputing set counts
    /// - Parameters:
    ///   - isActive: Bool
    ///   - restEndsAt: Date?
    ///   - statusMessage: String?
    func updateRestAndActive(
        isActive: Bool,
        restEndsAt: Date?,
        statusMessage: String? = nil
    ) {
        liveActivityManager.updateRestAndActive(isActive: isActive, restEndsAt: restEndsAt, statusMessage: statusMessage)
    }
}

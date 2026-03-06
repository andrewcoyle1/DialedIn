//
//  WorkoutTrackerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 09/12/2025.
//

import Foundation
import HealthKit

/// Parameters for updating a workout live activity's status and metrics.
struct LiveActivityUpdateParams {
    let session: WorkoutSessionModel
    let isActive: Bool
    let currentExerciseIndex: Int
    let restEndsAt: Date?
    let statusMessage: String?
    let totalVolumeKg: Double?
    let elapsedTime: TimeInterval?
}

/// Interactor protocol for handling all interactions between the Workout Tracker view model
/// and data/services, supporting HealthKit session handling, local persistence, notifications,
/// user event tracking, rest timing, preferences, and history management.
@MainActor
protocol WorkoutTrackerInteractor: GlobalInteractor {

    // MARK: - User and Session Properties

    /// The current logged-in user, or nil if not available.
    var currentUser: UserModel? { get }
    /// The favourite gym profile of the user, or nil if not available
    var favouriteGymProfile: GymProfileModel? { get }

    func setActiveWorkoutGymProfile(_ profile: GymProfileModel?)

    func getGymProfile(gymProfileId: String) async throws -> GymProfileModel
    
    /// The current rest end time for the active session, if any.
    var restEndTime: Date? { get }
    
    /// The current active workout session, if any.
    var activeSession: WorkoutSessionModel? { get }

    // MARK: - Workout Session Configuration & Lifecycle

    /// Set the configuration for a HealthKit workout session.
    func setWorkoutConfiguration(
        activityType: HKWorkoutActivityType,
        location: HKWorkoutSessionLocationType
    )

    func startWorkout(workout: WorkoutSessionModel)
    
    /// Create a new workout session and store it locally.
    func saveWorkoutSession(_ session: WorkoutSessionModel) async throws
    func updateActiveSession(_ session: WorkoutSessionModel) throws
    
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel
    /// End a remote (possibly HealthKit) workout session asynchronously at provided date.

    func endWorkoutSession(_ session: WorkoutSessionModel) async throws
    func deleteActiveSession() throws 
    /// End the current workout and persist/close resources as needed.
    func endWorkout()

    /// Discard the current workout without saving to HealthKit.
    func discardWorkout()

    var allExercises: [ExerciseModel] { get }
    
    // MARK: - Live Activity & Status Updates

    /// Ensure the associated live activity for a workout is continued or started.
    func ensureLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?,
        statusMessage: String?
    )

    /// End any running live activity for the provided workout session.
    func endLiveActivity(
        session: WorkoutSessionModel,
        isCompleted: Bool,
        statusMessage: String?
    )

    /// Update live activity status and metrics for widgets/external presentation.
    func updateLiveActivity(params: LiveActivityUpdateParams)

    func discardLiveActivity() async 
    // MARK: - Workout History

    /// Lookup the last completed session for a given template and author, if present.
    func getLastCompletedSessionForTemplate(
        templateId: String,
        authorId: String
    ) async throws -> WorkoutSessionModel?

    // MARK: - Rest & Notifications

    func schedulePushNotification(delegate: PushNotificationDelegate) async throws
    
    /// Start a rest timer for the specified duration in seconds,
    /// associated with the current session/exercise state.
    func startRest(
        durationSeconds: Int,
        session: WorkoutSessionModel,
        currentExerciseIndex: Int
    )

    /// Cancel any running rest timer.
    func cancelRest()

    /// The current workout settings.
    var workoutSettings: WorkoutSettings { get }
    
    func addWorkoutStreakEvent() async throws

    /// Load unit preferences for an exercise template.
    func getPreference(templateId: String) -> ExerciseUnitPreference

}

extension CoreInteractor: WorkoutTrackerInteractor { }

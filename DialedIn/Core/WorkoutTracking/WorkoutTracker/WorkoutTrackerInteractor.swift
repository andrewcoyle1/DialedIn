//
//  WorkoutTrackerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 09/12/2025.
//

import Foundation
import HealthKit

/// Interactor protocol for handling all interactions between the Workout Tracker view model
/// and data/services, supporting HealthKit session handling, local persistence, notifications,
/// user event tracking, rest timing, preferences, and history management.
protocol WorkoutTrackerInteractor {

    // MARK: - User and Session Properties

    /// The current logged-in user, or nil if not available.
    var currentUser: UserModel? { get }
    
    /// The current rest end time for the active session, if any.
    var restEndTime: Date? { get }
    
    /// The current active workout session, if any.
    var activeSession: WorkoutSessionModel? { get }
    
    /// The current HealthKit workout session state, if available.
    var workoutSessionState: HKWorkoutSessionState? { get }

    // MARK: - Workout Session Configuration & Lifecycle

    /// Set the configuration for a HealthKit workout session.
    func setWorkoutConfiguration(
        activityType: HKWorkoutActivityType,
        location: HKWorkoutSessionLocationType
    )

    /// Start a new workout with the given session model.
    func startWorkout(workout: WorkoutSessionModel)

    /// Retrieve a local workout session by its unique identifier.
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel

    /// Retrieve the currently active local workout session, if any.
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel?

    /// Create a new workout session and store it locally.
    func createWorkoutSession(session: WorkoutSessionModel) async throws

    /// Mark a local workout session as ended at the given date.
    func endLocalWorkoutSession(id: String, at endedAt: Date) throws

    /// End a workout session and optionally mark it as completed if scheduled.
    func endActiveSession(markScheduledComplete: Bool) async

    /// End a remote (possibly HealthKit) workout session asynchronously at provided date.
    func endWorkoutSession(id: String, at endedAt: Date) async throws

    /// End the current workout and persist/close resources as needed.
    func endWorkout()

    /// Delete a local workout session by its identifier.
    func deleteLocalWorkoutSession(id: String) throws

    /// Update a local workout session with new values.
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws

    /// Set a local session as the current active one, passing nil to clear.
    func setActiveLocalWorkoutSession(_ session: WorkoutSessionModel?) throws

    /// Minimize the active workout session, e.g., background the activity in the UI.
    func minimizeActiveSession()

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

    // Update live activity status and metrics for widgets/external presentation.
    // swiftlint:disable:next function_parameter_count
    func updateLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?,
        statusMessage: String?,
        totalVolumeKg: Double?,
        elapsedTime: TimeInterval?
    )

    // MARK: - Workout History

    /// Lookup the last completed session for a given template and author, if present.
    func getLastCompletedSessionForTemplate(
        templateId: String,
        authorId: String
    ) async throws -> WorkoutSessionModel?

    /// Add a workout set result or data point to the local exercise history.
    func addLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws

    /// Persist a new history entry to remote or cloud store.
    func createExerciseHistory(entry: ExerciseHistoryEntryModel) async throws

    // MARK: - Rest & Notifications

    /// Start a rest timer for the specified duration in seconds,
    /// associated with the current session/exercise state.
    func startRest(
        durationSeconds: Int,
        session: WorkoutSessionModel,
        currentExerciseIndex: Int
    )

    /// Cancel any running rest timer.
    func cancelRest()

    /// Schedule a push notification at a future date.
    func schedulePushNotification(
        identifier: String,
        title: String,
        body: String,
        date: Date
    ) async throws

    /// Remove any pending notifications matching given identifiers.
    func removePendingNotifications(withIdentifiers identifiers: [String]) async

    // MARK: - Analytics & Event Logging

    /// Track an analytics or custom event with optional parameters.
    func trackEvent(
        eventName: String,
        parameters: [String: Any]?,
        type: LogType
    )
}

extension CoreInteractor: WorkoutTrackerInteractor { }

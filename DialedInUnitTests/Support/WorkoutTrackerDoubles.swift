//
//  WorkoutTrackerDoubles.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 20/09/2026.
//

import Foundation
import SwiftUI
import HealthKit
@testable import DialedIn

/// The tracker's interactor and router doubles.
///
/// `WorkoutTrackerInteractor` declares around thirty methods — HealthKit, the Live Activity, rest
/// timing and persistence — so the doubles are longer than the tests that use them. They live here
/// to keep the test file itself readable.

final class WorkoutTrackerInteractorDouble: SpyGlobalInteractor, WorkoutTrackerInteractor {
    var currentUser: UserModel? = UserModel(userId: "author-1")
    var favouriteGymProfile: GymProfileModel?
    var restEndTime: Date?
    var activeSession: WorkoutSessionModel?
    var allExercises: [ExerciseModel] = []
    var workoutSettings: WorkoutSettings = WorkoutSettings(authorId: "author-1")
    var preferences: [String: ExerciseUnitPreference] = [:]
    var lastCompletedSession: WorkoutSessionModel?

    private(set) var savedActiveSessions: [WorkoutSessionModel] = []
    private(set) var endedSessions: [WorkoutSessionModel] = []
    private(set) var startedRests: [Int] = []
    private(set) var didCancelRest = false
    private(set) var didAddStreakEvent = false
    private(set) var endedLiveActivities: [(isCompleted: Bool, statusMessage: String?)] = []
    var endWorkoutSessionError: Error?

    /// Consumed one per call, so a test can say "fails twice, then works" — which is the whole
    /// point of the retry. Falls back to `endWorkoutSessionError` once it runs dry.
    var endWorkoutSessionErrors: [Error?] = []
    private(set) var endWorkoutSessionAttempts = 0
    var streakError: Error?
    private(set) var stravaUploads: [String] = []
    private(set) var preparedSounds: [SoundEffectFile] = []
    private(set) var playedSounds: [SoundEffectFile] = []

    func setActiveWorkoutGymProfile(_ profile: GymProfileModel?) { }
    func getGymProfile(gymProfileId: String) async throws -> GymProfileModel {
        GymProfileModel(id: gymProfileId, authorId: "author-1", name: "Home Gym")
    }
    func canRequestHealthDataAuthorisation() -> Bool { false }
    func requestHealthKitAuthorisation() async throws { }
    func needsAuthorisationForRequiredTypes() -> Bool { false }
    func setWorkoutConfiguration(activityType: HKWorkoutActivityType, location: HKWorkoutSessionLocationType) { }

    func startWorkout(workout: WorkoutSessionModel) { }
    func saveWorkoutSession(_ session: WorkoutSessionModel) async throws { }
    func updateActiveSession(_ session: WorkoutSessionModel) throws {
        savedActiveSessions.append(session)
        activeSession = session
    }
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel {
        guard let activeSession else { throw WorkoutTrackerPresenter.WorkoutTrackerError.noActiveWorkout }
        return activeSession
    }
    func endWorkoutSession(_ session: WorkoutSessionModel) async throws {
        endWorkoutSessionAttempts += 1
        let error = endWorkoutSessionErrors.isEmpty ? endWorkoutSessionError : endWorkoutSessionErrors.removeFirst()
        if let error { throw error }
        endedSessions.append(session)
    }
    func deleteActiveSession() throws { activeSession = nil }
    func endWorkout() { }
    func discardWorkout() { }

    func ensureLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?,
        statusMessage: String?
    ) { }
    func endLiveActivity(session: WorkoutSessionModel, isCompleted: Bool, statusMessage: String?) {
        endedLiveActivities.append((isCompleted: isCompleted, statusMessage: statusMessage))
    }
    func updateLiveActivity(params: LiveActivityUpdateParams) { }
    func discardLiveActivity() async { }

    /// Records the program filter the presenter asked for, and honours it against
    /// `completedSessions` when that is set — so a test can assert both the request and the result.
    private(set) var lastCompletedSessionLookups: [String?] = []
    var completedSessions: [WorkoutSessionModel]?

    func getLastCompletedSessionForTemplate(
        templateId: String,
        authorId: String,
        inTrainingProgramId: String?
    ) async throws -> WorkoutSessionModel? {
        lastCompletedSessionLookups.append(inTrainingProgramId)
        guard let completedSessions else { return lastCompletedSession }
        return completedSessions
            .filter { $0.workoutTemplateId == templateId }
            .filter { inTrainingProgramId == nil || $0.trainingProgramId == inTrainingProgramId }
            .max { ($0.endedAt ?? .distantPast) < ($1.endedAt ?? .distantPast) }
    }

    /// Serves `completedSessions` newest first, so the progression history reads the way the real
    /// lookup does.
    func getLastCompletedSessionsForTemplate(
        templateId: String,
        authorId: String,
        inTrainingProgramId: String?,
        limit: Int
    ) async throws -> [WorkoutSessionModel] {
        let sessions = completedSessions ?? [lastCompletedSession].compactMap { $0 }
        return Array(
            sessions
                .filter { $0.workoutTemplateId == templateId }
                .filter { inTrainingProgramId == nil || $0.trainingProgramId == inTrainingProgramId }
                .sorted { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }
                .prefix(max(limit, 0))
        )
    }

    // MARK: - Previous workout reference

    /// The double serves `completedSessions` through the real `PreviousWorkoutReferenceResolving`
    /// extension, so the tracker tests exercise the shipped switch and fallback rather than a
    /// second copy of them living here.
    var previousWorkoutReferenceScope: PreviousWorkoutReferenceOption {
        workoutSettings.previousWorkoutReference
    }

    /// Every scope request the resolver made, as `(workoutTemplateId, programId)` for a template
    /// lookup and `(nil, programId)` for an any-exercise one.
    private(set) var previousSessionLookups: [(templateId: String?, programId: String?)] = []

    func completedSessionsForWorkoutTemplate(
        templateId: String,
        authorId: String,
        inTrainingProgramId: String?,
        limit: Int
    ) async -> [WorkoutSessionModel] {
        previousSessionLookups.append((templateId: templateId, programId: inTrainingProgramId))
        lastCompletedSessionLookups.append(inTrainingProgramId)
        return (try? await getLastCompletedSessionsForTemplate(
            templateId: templateId,
            authorId: authorId,
            inTrainingProgramId: inTrainingProgramId,
            limit: limit
        )) ?? []
    }

    func completedSessionsContainingExercise(
        exerciseTemplateId: String,
        authorId: String,
        inTrainingProgramId: String?,
        limit: Int
    ) async -> [WorkoutSessionModel] {
        previousSessionLookups.append((templateId: nil, programId: inTrainingProgramId))
        let sessions = completedSessions ?? [lastCompletedSession].compactMap { $0 }
        return Array(
            sessions
                .filter { $0.endedAt != nil }
                .filter { $0.exercises.contains(where: { $0.templateId == exerciseTemplateId }) }
                .filter { inTrainingProgramId == nil || $0.trainingProgramId == inTrainingProgramId }
                .sorted { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }
                .prefix(max(limit, 0))
        )
    }

    /// What `progressionSuggestions(for:gymProfile:)` hands back, keyed by exercise `templateId`.
    var progressionSuggestionsByTemplateId: [String: ProgressionSuggestion] = [:]

    func progressionSuggestions(
        for session: WorkoutSessionModel,
        gymProfile: GymProfileModel?
    ) async -> [String: ProgressionSuggestion] {
        progressionSuggestionsByTemplateId
    }

    func schedulePushNotification(delegate: PushNotificationDelegate) async throws { }
    func startRest(durationSeconds: Int, session: WorkoutSessionModel, currentExerciseIndex: Int) {
        startedRests.append(durationSeconds)
        restEndTime = Date().addingTimeInterval(TimeInterval(durationSeconds))
    }
    func cancelRest() {
        didCancelRest = true
        restEndTime = nil
    }
    func prepareSoundEffect(sound: SoundEffectFile, simultaneousPlayers: Int) {
        preparedSounds.append(sound)
    }
    func playSoundEffect(sound: SoundEffectFile) {
        playedSounds.append(sound)
    }
    func addWorkoutStreakEvent() async throws {
        if let streakError { throw streakError }
        didAddStreakEvent = true
    }
    func getPreference(templateId: String) -> ExerciseUnitPreference {
        preferences[templateId] ?? ExerciseUnitPreference(exerciseModelId: templateId)
    }
    func preCompleteConsecutiveRestDays(after session: WorkoutSessionModel) async { }
    func uploadToStravaIfConnected(_ session: WorkoutSessionModel) async {
        stravaUploads.append(session.id)
    }
}

final class WorkoutTrackerRouterDouble: WorkoutTrackerRouter {
    let router: AnyRouter = TestRouting.anyRouter
    private(set) var shown: [String] = []

    func showExercisesPickerView(delegate: ExercisesPickerDelegate) { shown.append("exercisesPicker") }
    func showWorkoutNotesView(delegate: WorkoutNotesDelegate) { shown.append("workoutNotes") }
    func showWorkoutSettingsView(delegate: WorkoutSettingsDelegate) { shown.append("workoutSettings") }
    func showGymProfileView(delegate: GymProfileDelegate) { shown.append("gymProfile") }
}

extension RetryBackoff {

    /// A retry schedule a test can drive to its end in a millisecond.
    ///
    /// Injecting this rather than waiting out the real one is the difference between a test and a
    /// flake: the shipped schedule spends twenty-six seconds getting to the same answer.
    static let testImmediate = RetryBackoff(
        baseDelay: .milliseconds(1),
        multiplier: 1,
        maxAttempts: 4,
        maxTotalDelay: .seconds(1)
    )
}

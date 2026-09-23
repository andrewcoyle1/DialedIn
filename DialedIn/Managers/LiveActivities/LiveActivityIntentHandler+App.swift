//
//  LiveActivityIntentHandler+App.swift
//  DialedIn
//
//  The app's implementation of `LiveActivityIntentHandling`
//  (spec: docs/specs/live-activity.md §7.1).
//
//  A `LiveActivityIntent` runs in this process, so the button on the Live Activity can do the
//  work here and now rather than leaving a note in the app group for something to poll. The v1
//  hand-off did poll, from a timer that only started once HealthKit's `beginCollection` had
//  succeeded — which is why Complete Set advanced the widget and logged nothing on a phone where
//  HealthKit was declined.
//
//  Every action finishes by pushing the saved session to the activity, so the app is the single
//  source of truth for what the activity shows.
//

import Foundation

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)

@MainActor
final class AppLiveActivityIntentHandler: LiveActivityIntentHandling {

    private let workoutSessionManager: WorkoutSessionManager
    private let hkWorkoutManager: HKWorkoutManager
    private let liveActivityUpdater: any LiveActivityUpdating
    private let workoutSettingsManager: WorkoutSettingsManager
    private let exerciseSettingsManager: ExerciseSettingsManager
    private let exerciseModelManager: ExerciseModelManager

    /// The two side effects of finishing that are not the workout itself. Optional so a test can
    /// build the handler without them.
    private let streakManager: StreakManager?
    private let stravaManager: StravaManager?

    init(
        workoutSessionManager: WorkoutSessionManager,
        hkWorkoutManager: HKWorkoutManager,
        liveActivityUpdater: any LiveActivityUpdating,
        workoutSettingsManager: WorkoutSettingsManager,
        exerciseSettingsManager: ExerciseSettingsManager,
        exerciseModelManager: ExerciseModelManager,
        streakManager: StreakManager? = nil,
        stravaManager: StravaManager? = nil
    ) {
        self.workoutSessionManager = workoutSessionManager
        self.hkWorkoutManager = hkWorkoutManager
        self.liveActivityUpdater = liveActivityUpdater
        self.workoutSettingsManager = workoutSettingsManager
        self.exerciseSettingsManager = exerciseSettingsManager
        self.exerciseModelManager = exerciseModelManager
        self.streakManager = streakManager
        self.stravaManager = stravaManager
    }

    // MARK: - LiveActivityIntentHandling

    /// Log the set with this id and start the rest that follows it.
    ///
    /// The values logged are the set's own — the weight, reps, duration and distance already on it
    /// — not the activity's `target*` fields, which are a formatted copy that can be a push behind.
    /// Completing a set on the tracker does exactly the same thing: it sets `completedAt` and
    /// leaves the numbers alone.
    func completeSet(id: String) async {
        guard let session = workoutSessionManager.activeSession,
              let location = locate(setId: id, in: session) else { return }

        let exercise = session.exercises[location.exerciseIndex]
        let set = exercise.sets[location.setIndex]
        guard set.completedAt == nil else { return }

        var exercises = session.exercises
        exercises[location.exerciseIndex].sets[location.setIndex].completedAt = Date()

        var updated = session
        updated.updateExercises(exercises)
        guard save(updated) else { return }

        // The exercise to show is the next one with work left, not the one just finished: after
        // its last set the finished exercise has no target, and a banner with no target has no
        // way out once the rest ends.
        let nextIndex = currentExerciseIndex(in: updated)
        startRest(after: set, in: exercise, session: updated, exerciseIndex: nextIndex)
        push(updated, exerciseIndex: nextIndex)
    }

    /// Correct the reps of a set already logged, while the rest after it is still running.
    ///
    /// Reps and nothing else: the correction is about what was lifted, not when, so `completedAt`
    /// stays as it was logged. Outside the rest there is no set to correct and the tap is dropped.
    func adjustLastSetReps(id: String, delta: Int) async {
        guard let restEndTime = hkWorkoutManager.restEndTime, restEndTime > Date() else { return }
        guard let session = workoutSessionManager.activeSession,
              let location = locate(setId: id, in: session) else { return }

        var exercises = session.exercises
        let base = exercises[location.exerciseIndex].sets[location.setIndex].reps ?? 0
        exercises[location.exerciseIndex].sets[location.setIndex].reps = min(max(base + delta, 0), 99)

        var updated = session
        updated.updateExercises(exercises)
        guard save(updated) else { return }

        push(updated, exerciseIndex: currentExerciseIndex(in: updated))
    }

    // MARK: - Fallback drain

    /// Apply anything an intent left in the app group because no handler was registered when it
    /// ran — the cold-launch race, where `perform()` could in principle beat `didFinishLaunching`.
    /// Nothing else reads those slots any more, so without this a tap that lost the race would be
    /// lost with it. Called once at registration; the slots are cleared whether or not they still
    /// apply, so a stale note from a workout since finished is dropped rather than replayed later.
    func drainFallbackSlots() async {
        await drain(
            setCompletion: SharedWorkoutStorage.pendingSetCompletion,
            adjustment: SharedWorkoutStorage.pendingSetAdjustment,
            workoutCompletion: SharedWorkoutStorage.pendingWorkoutCompletion
        )
        SharedWorkoutStorage.clearPendingSetCompletion()
        SharedWorkoutStorage.clearPendingSetAdjustment()
        SharedWorkoutStorage.clearPendingWorkoutCompletion()
    }

    /// The drain with its inputs passed in, so a test can drive it without the app group.
    func drain(
        setCompletion: SharedWorkoutStorage.PendingSetCompletion?,
        adjustment: SharedWorkoutStorage.PendingSetAdjustment?,
        workoutCompletion: SharedWorkoutStorage.PendingWorkoutCompletion?
    ) async {
        if let setCompletion {
            await completeSet(id: setCompletion.setId)
        }
        if let adjustment {
            // An absolute count, and the rest it belonged to has very likely passed by now, so it
            // bypasses the live-rest guard the tap itself has.
            setReps(adjustment.reps, forSetId: adjustment.setId)
        }
        if let workoutCompletion, workoutSessionManager.activeSession?.id == workoutCompletion.sessionId {
            await completeWorkout()
        }
    }

    private func setReps(_ reps: Int, forSetId id: String) {
        guard let session = workoutSessionManager.activeSession,
              let location = locate(setId: id, in: session) else { return }
        var exercises = session.exercises
        exercises[location.exerciseIndex].sets[location.setIndex].reps = min(max(reps, 0), 99)
        var updated = session
        updated.updateExercises(exercises)
        guard save(updated) else { return }
        push(updated, exerciseIndex: currentExerciseIndex(in: updated))
    }

    /// Lengthen (or shorten) the running rest, never past now.
    func adjustRest(by seconds: Int) async {
        guard let restEndTime = hkWorkoutManager.restEndTime,
              let session = workoutSessionManager.activeSession else { return }

        let proposed = restEndTime.addingTimeInterval(TimeInterval(seconds))
        let remaining = max(1, proposed.timeIntervalSinceNow)
        let exerciseIndex = currentExerciseIndex(in: session)

        // `startRest` cancels the running timer, reschedules on the new end and pushes, so the
        // adjustment goes through the one place that owns the rest rather than moving a date.
        hkWorkoutManager.startRest(duration: remaining, session: session, currentExerciseIndex: exerciseIndex)
        push(session, exerciseIndex: exerciseIndex)
    }

    /// End the running rest now.
    func skipRest() async {
        hkWorkoutManager.cancelRest()
        guard let session = workoutSessionManager.activeSession else { return }
        push(session, exerciseIndex: currentExerciseIndex(in: session))
    }

    /// Finish the workout: HealthKit, the session and the activity all end as they do from the
    /// tracker's Finish button.
    func completeWorkout() async {
        guard var session = workoutSessionManager.activeSession else { return }

        hkWorkoutManager.cancelRest()
        session.endSession(at: Date())
        SharedWorkoutStorage.clearHKStartedSessionId()
        hkWorkoutManager.endWorkout()

        var saved = true
        do {
            try await workoutSessionManager.endWorkoutSession(session)
        } catch {
            saved = false
        }

        liveActivityUpdater.endLiveActivity(
            session: session,
            isCompleted: saved,
            statusMessage: saved ? "Workout ended & saved." : "Workout ended, but could not be saved."
        )

        if let streakManager {
            _ = try? await streakManager.addStreakEvent()
        }
        if let stravaManager, stravaManager.isConnected, session.endedAt != nil {
            try? await stravaManager.uploadWorkout(session)
        }
    }

    // MARK: - Helpers

    private struct SetLocation {
        let exerciseIndex: Int
        let setIndex: Int
    }

    private func locate(setId: String, in session: WorkoutSessionModel) -> SetLocation? {
        for (exerciseIndex, exercise) in session.exercises.enumerated() {
            if let setIndex = exercise.sets.firstIndex(where: { $0.id == setId }) {
                return SetLocation(exerciseIndex: exerciseIndex, setIndex: setIndex)
            }
        }
        return nil
    }

    /// Saves through the active session, and answers whether it stuck. A failed write means the
    /// set was not logged, so nothing downstream of it should run either.
    private func save(_ session: WorkoutSessionModel) -> Bool {
        do {
            try workoutSessionManager.updateActiveSession(session)
            return true
        } catch {
            return false
        }
    }

    /// The rest the set-row presenter would have started for this set, through the same rules.
    private func startRest(
        after set: WorkoutSetModel,
        in exercise: WorkoutExerciseModel,
        session: WorkoutSessionModel,
        exerciseIndex: Int
    ) {
        let settings = workoutSettingsManager.workoutSettings
        guard settings.useRestTimers else { return }

        let context = RestDurationRules.ExerciseContext(
            restOverrideSeconds: exerciseSettingsManager.restOverride(for: exercise.templateId),
            exerciseTypeRawValue: exerciseModelManager.allExercises
                .first(where: { $0.id == exercise.templateId })?.type?.rawValue
        )

        guard let duration = RestDurationRules.restAfterCompleting(
            set,
            in: exercise,
            settings: settings,
            context: context
        ) else { return }

        hkWorkoutManager.startRest(
            durationSeconds: duration,
            session: session,
            currentExerciseIndex: exerciseIndex
        )
    }

    /// Pushes the saved session to the activity, the same shape `WorkoutTrackerPresenter`
    /// pushes when the tracker is on screen.
    ///
    /// `isActive` is true rather than read from the HealthKit session state: a workout the user
    /// has not paused is under way whether or not HealthKit ever started collecting, and reading
    /// the state would show the banner as paused on every phone that declined HealthKit.
    private func push(_ session: WorkoutSessionModel, exerciseIndex: Int) {
        let restEndsAt = hkWorkoutManager.restEndTime
        let isResting = restEndsAt.map { $0 > Date() } ?? false
        liveActivityUpdater.updateLiveActivity(params: LiveActivityUpdateParams(
            session: session,
            isActive: true,
            currentExerciseIndex: exerciseIndex,
            restEndsAt: isResting ? restEndsAt : nil,
            statusMessage: isResting ? "Resting" : nil,
            totalVolumeKg: nil,
            elapsedTime: nil
        ))
    }

    /// The exercise the user is on: the first with a set still to log, or the last one when there
    /// is nothing left.
    private func currentExerciseIndex(in session: WorkoutSessionModel) -> Int {
        if let index = session.exercises.firstIndex(where: { exercise in
            !exercise.sets.isEmpty && !exercise.sets.allSatisfy { $0.completedAt != nil }
        }) {
            return index
        }
        return max(0, session.exercises.count - 1)
    }
}

#endif

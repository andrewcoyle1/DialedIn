//
//  LiveActivityManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/09/2025.
//

import Foundation
#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
import ActivityKit
// Models used to populate attributes live within the same target

@Observable
@MainActor
class LiveActivityManager: LiveActivityUpdating {
    
    private let logger: LogManager

    /// Finds the system's activity for a session when `currentActivity` is nil. Every handler push
    /// after iOS has evicted the app runs in a fresh process where nothing has started or ensured
    /// an activity, so the manager has to find the one on the Lock Screen by session id or every
    /// action is dropped. Injected so tests, which cannot start an activity, can see what the
    /// manager asked for and hand one back.
    private let activityLookup: (String) -> Activity<WorkoutActivityAttributes>?

    init(
        logger: LogManager,
        activityLookup: @escaping (String) -> Activity<WorkoutActivityAttributes>? = { sessionId in
            Activity<WorkoutActivityAttributes>.activities.first { $0.attributes.sessionId == sessionId }
        }
    ) {
        self.logger = logger
        self.activityLookup = activityLookup
    }
    
	// The currently active Workout Live Activity
	private var currentActivity: Activity<WorkoutActivityAttributes>?
	
	// Cache the last content state to avoid unnecessary updates
	private(set) var lastContentState: WorkoutActivityAttributes.ContentState?
    
	// MARK: - Public API
    
    /// Ensure a Workout Live Activity using data from the given session
    /// - Parameters:
    ///   - session: The workout session used to seed immutable attributes
    ///   - isActive: Whether the workout timer is running
    ///   - currentExerciseIndex: Index of the currently focused exercise in the session
    ///   - restEndsAt: Optional rest countdown end time
    func ensureLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool = true,
        currentExerciseIndex: Int = 0,
        restEndsAt: Date? = nil
    ) {
        // Attempt to find an existing activity for this session
        if let existing = resolveActivity(sessionId: session.id), Self.isUpdatable(existing) {
            updateLiveActivity(
                params: LiveActivityUpdateParams(
                    session: session,
                    isActive: isActive,
                    currentExerciseIndex: currentExerciseIndex,
                    restEndsAt: restEndsAt
                )
            )
            return
        }

        // Otherwise start a new live activity
        self.startLiveActivity(
            session: session,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndsAt
        )
    }

    /// Push the session's current state to the Live Activity.
    func updateLiveActivity(params: LiveActivityUpdateParams) {
        // No Start here: this only builds the content state and hands it to the private overload,
        // which logs the attempt. Tracking in both counted every update twice.
        let updatedState = makeContentState(
            session: params.session,
            isActive: params.isActive,
            currentExerciseIndex: params.currentExerciseIndex,
            restEndsAt: params.restEndsAt
        )
        
        self.updateLiveActivity(sessionId: params.session.id, contentState: updatedState)
    }
    
    /// End the session's Live Activity, with the summary when the workout completed.
    func endLiveActivity(session: WorkoutSessionModel, isCompleted: Bool = true) {
        logger.trackEvent(event: Event.endLiveActivityStart)
        
        // Build final state with summary metrics if completed
        var finalState = makeContentState(session: session, isActive: false, currentExerciseIndex: 0, restEndsAt: nil)
        finalState.isWorkoutEnded = true
        
        // Add summary metrics for completed workouts
        if isCompleted {
            let elapsedTime = Date().timeIntervalSince(session.dateCreated)
            let allSets = session.exercises.flatMap { $0.sets }
            // Sets pair; volume does not — both sides of a set are real work lifted.
            let completedSetsCount = session.exercises.reduce(0) { $0 + $1.sets.fullyCompletedPairedSetCount }
            let totalVolume = allSets.compactMap { set -> Double? in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }.reduce(0.0, +)
            
            finalState.finalDurationSeconds = elapsedTime
            finalState.finalVolumeKg = totalVolume > 0 ? totalVolume : nil
            finalState.finalCompletedSetsCount = completedSetsCount
        }
        
        lastContentState = finalState
        
        // Use different dismissal policies based on completion state
        let dismissalPolicy: ActivityUIDismissalPolicy = isCompleted ? .default : .immediate

        guard let activity = resolveActivity(sessionId: session.id) else {
            logger.trackEvent(event: Event.endLiveActivityFail(error: LiveActivityError.noUpdatableActivity))
            return
        }
        Task {
            await activity.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: dismissalPolicy)
            logger.trackEvent(event: Event.endLiveActivitySuccess)
        }
    }

    /// `currentActivity` when it is this session's, else whatever the lookup finds, adopted and
    /// observed from here on. Nil when the system has no activity for the session.
    private func resolveActivity(sessionId: String) -> Activity<WorkoutActivityAttributes>? {
        if let currentActivity, currentActivity.attributes.sessionId == sessionId {
            return currentActivity
        }
        guard let found = activityLookup(sessionId) else { return nil }
        currentActivity = found
        observeActivity(activity: found)
        return found
    }

    private static func isUpdatable(_ activity: Activity<WorkoutActivityAttributes>) -> Bool {
        activity.activityState == .active || activity.activityState == .stale
    }

    /// Start a Workout Live Activity using data from the given session
    /// - Parameters:
    ///   - session: The workout session used to seed immutable attributes
    ///   - isActive: Whether the workout timer is running
    ///   - currentExerciseIndex: Index of the currently focused exercise in the session
    ///   - restEndsAt: Optional rest countdown end time
    private func startLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool = true,
        currentExerciseIndex: Int = 0,
        restEndsAt: Date? = nil
    ) {
        logger.trackEvent(event: Event.startLiveActivityStart)

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.trackEvent(event: Event.liveActivitiesNotEnabled)
            return
        }

        // `ensureLiveActivity` has already looked for this session's activity. Anything else still
        // showing belongs to an earlier workout and would otherwise be adopted with the wrong name.
        for other in Activity<WorkoutActivityAttributes>.activities where other.attributes.sessionId != session.id {
            Task { await other.end(nil, dismissalPolicy: .immediate) }
        }

        do {
            let (attributes, initialState) = buildAttributesAndInitialState(
                session: session,
                isActive: isActive,
                currentExerciseIndex: currentExerciseIndex,
                restEndsAt: restEndsAt
            )
            try requestAndSetupActivity(attributes: attributes, initialState: initialState)
            logger.trackEvent(event: Event.startLiveActivitySuccess)
        } catch {
            logger.trackEvent(event: Event.startLiveActivityFail(error: error))
        }
    }
    
    private func updateLiveActivity(sessionId: String, contentState: WorkoutActivityAttributes.ContentState) {
        let activity = resolveActivity(sessionId: sessionId)

        // Only update if meaningful changes occurred. A skipped no-op is not an attempt, so the
        // Start belongs below the guard — logging it above gave every unchanged tick a Start with
        // no terminal event and buried the real failures.
        guard shouldUpdateLiveActivity(contentState: contentState, on: activity) else { return }

        logger.trackEvent(event: Event.updateLiveActivityStart)

        // Guard activity existence and acceptable state to avoid runtime errors
        guard let activity, Self.isUpdatable(activity) else {
            // The activity was dismissed or ended under us. This used to fall out of the `if` with
            // nothing logged, so a Live Activity that stopped updating mid-workout was invisible.
            logger.trackEvent(event: Event.updateLiveActivityFail(error: LiveActivityError.noUpdatableActivity))
            return
        }
        // Recorded only once there is something to push to: a dropped push that was remembered
        // here made the equality gate swallow the identical retry.
        self.lastContentState = contentState

        Task {
            await activity.update(ActivityContent(state: contentState, staleDate: contentState.restEndsAt))
            logger.trackEvent(event: Event.updateLiveActivitySuccess)
        }
    }
        
    /// Any difference is worth a push. This used to compare four fields, which was enough while
    /// only those changed between pushes; the reps correction changes `lastLoggedReps` and nothing
    /// else, and a four-field gate dropped it on the floor. The per-second tick still produces an
    /// identical state (elapsed time is not part of it), so the gate keeps that quiet.
    ///
    /// An intent pushes its loading state straight to ActivityKit, behind this memory. A push that
    /// otherwise changes nothing — a tap on a set already logged — is still owed while that flag is
    /// up, or the button stays dead.
    private func shouldUpdateLiveActivity(
        contentState: WorkoutActivityAttributes.ContentState,
        on activity: Activity<WorkoutActivityAttributes>?
    ) -> Bool {
        lastContentState != contentState || activity?.content.state.isProcessingIntent == true
    }
    
    /// Forget the activity once the user has dismissed it, so a later update does not talk to a
    /// handle that is gone.
    private func observeActivity(activity: Activity<WorkoutActivityAttributes>) {
        Task { @MainActor in
            for await activityState in activity.activityStateUpdates where activityState == .dismissed {
                self.cleanupDismissedActivity()
            }
        }
    }
        
    private func cleanupDismissedActivity() {
        self.currentActivity = nil
        self.lastContentState = nil
    }
    
    // MARK: - Helpers
    
    // MARK: - Internal helpers for activity creation/reuse
    private func buildAttributesAndInitialState(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?
    ) -> (WorkoutActivityAttributes, WorkoutActivityAttributes.ContentState) {
        let attributes = WorkoutActivityAttributes(sessionId: session.id, workoutName: session.name)
        let initialState = makeContentState(
            session: session,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndsAt
        )
        return (attributes, initialState)
    }

    private func requestAndSetupActivity(
        attributes: WorkoutActivityAttributes,
        initialState: WorkoutActivityAttributes.ContentState
    ) throws {
        lastContentState = initialState
        let activity = try Activity.request(
            attributes: attributes,
            content: ActivityContent(state: initialState, staleDate: nil),
            pushType: nil
        )
        self.currentActivity = activity
        observeActivity(activity: activity)
    }

    func makeContentState(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?
    ) -> WorkoutActivityAttributes.ContentState {
        let totals = computeTotals(session: session)
        let currentExerciseIndex = Self.exerciseIndexWithWorkLeft(from: currentExerciseIndex, in: session)
        let current = deriveCurrentExerciseData(session: session, index: currentExerciseIndex)
        let next = deriveNextExerciseData(session: session, index: currentExerciseIndex)
        // The correction window is exactly the rest that follows a logged set (spec §4). Deriving
        // it from the rest rather than storing it is what clears it when the rest ends: the state
        // is rebuilt on every update, so there is no bookkeeping to get wrong.
        let lastLogged = isResting(restEndsAt: restEndsAt) ? lastCompletedSet(session: session) : nil

        return WorkoutActivityAttributes.ContentState(
            isActive: isActive,
            completedSetsCount: totals.completedSetsCount,
            totalSetsCount: totals.totalSetsCount,
            currentExerciseName: current.name,
            currentExerciseImageName: current.imageName,
            currentExerciseIndex: currentExerciseIndex,
            totalExercisesCount: session.exercises.count,
            currentExerciseCompletedSetsCount: current.position.completed,
            currentExerciseTotalSetsCount: current.position.total,
            targetIsWarmup: current.position.isWarmup,
            targetSetId: current.targetSet?.id,
            targetWeightKg: current.targetSet?.weightKg,
            targetReps: current.targetSet?.reps,
            targetDistanceMeters: current.targetSet?.distanceMeters,
            targetDurationSec: current.targetSet?.durationSec,
            restEndsAt: restEndsAt,
            progress: totals.progress,
            isWorkoutEnded: false,
            finalDurationSeconds: nil,
            finalVolumeKg: nil,
            finalCompletedSetsCount: nil,
            isProcessingIntent: false,
            isAllSetsComplete: totals.isAllSetsComplete,
            lastLoggedSetId: lastLogged?.id,
            lastLoggedReps: lastLogged?.reps,
            lastLoggedWeightKg: lastLogged?.weightKg,
            nextExerciseName: next.name,
            nextExerciseFirstTargetWeightKg: next.firstTarget?.weightKg,
            nextExerciseFirstTargetReps: next.firstTarget?.reps,
            nextExerciseFirstTargetDistanceMeters: next.firstTarget?.distanceMeters,
            nextExerciseFirstTargetDurationSec: next.firstTarget?.durationSec
        )
    }

    /// True while a rest is still running, which is the only window in which the last logged set
    /// can be corrected from the activity.
    private func isResting(restEndsAt: Date?) -> Bool {
        guard let restEndsAt else { return false }
        return restEndsAt > Date()
    }

    /// The set completed most recently anywhere in the session — the one the rest belongs to.
    private func lastCompletedSet(session: WorkoutSessionModel) -> WorkoutSetModel? {
        session.exercises
            .flatMap { $0.sets }
            .filter { $0.completedAt != nil }
            .max { ($0.completedAt ?? .distantPast) < ($1.completedAt ?? .distantPast) }
    }

    /// Only isActive and rest change; everything else is carried over from the last push, so the
    /// exercise the activity is showing survives a rest ending. The same door as every other push:
    /// logged, gated on equality, remembered. Nothing to carry over means nothing has reached an
    /// activity yet, and there is no exercise to preserve.
    func updateRestAndActive(isActive: Bool, restEndsAt: Date?) {
        guard var state = lastContentState, let sessionId = currentActivity?.attributes.sessionId else { return }
        state.isActive = isActive
        state.restEndsAt = restEndsAt
        updateLiveActivity(sessionId: sessionId, contentState: state)
    }

    // MARK: - Derived state helpers
    private struct Totals {
        let totalSetsCount: Int
        let completedSetsCount: Int
        let progress: Double
        let isAllSetsComplete: Bool
    }

    private func computeTotals(session: WorkoutSessionModel) -> Totals {
        let totalSetsCount = session.exercises.reduce(0) { $0 + $1.sets.pairedSetCount }
        let completedSetsCount = session.exercises.reduce(0) { $0 + $1.sets.fullyCompletedPairedSetCount }
        let progress = totalSetsCount > 0 ? Double(completedSetsCount) / Double(totalSetsCount) : 0
        let isAllSetsComplete = totalSetsCount > 0 && completedSetsCount == totalSetsCount

        return Totals(
            totalSetsCount: totalSetsCount,
            completedSetsCount: completedSetsCount,
            progress: progress,
            isAllSetsComplete: isAllSetsComplete
        )
    }

    private struct NextExerciseData {
        let name: String?
        let firstTarget: WorkoutSetModel?
    }

    /// The exercise after the current one, with the first working set it prescribes. Nil on the
    /// last exercise, which is what makes `.exerciseDone` unreachable there.
    private func deriveNextExerciseData(session: WorkoutSessionModel, index: Int) -> NextExerciseData {
        guard (0..<session.exercises.count).contains(index + 1) else {
            return NextExerciseData(name: nil, firstTarget: nil)
        }
        let nextExercise = session.exercises[index + 1]
        let firstWorkingSet = nextExercise.sets.first { !$0.isWarmup } ?? nextExercise.sets.first
        return NextExerciseData(name: nextExercise.name, firstTarget: firstWorkingSet)
    }

    private struct CurrentExerciseData {
        let name: String?
        let imageName: String?
        let position: ExercisePosition
        let targetSet: WorkoutSetModel?
    }

    /// Where the user is in an exercise, counted within the group the next set belongs to.
    struct ExercisePosition: Equatable {
        let completed: Int
        let total: Int
        let isWarmup: Bool
    }

    /// "Warmup 1 of 2" while a warm-up is next, "Set 1 of 4" once the working sets start: the
    /// warm-ups are their own short count rather than the first two of six. With nothing left the
    /// working sets are counted, so a finished exercise reads as all of them done.
    static func exercisePosition(in sets: [WorkoutSetModel]) -> ExercisePosition {
        let isWarmup = sets.first { $0.completedAt == nil }?.isWarmup ?? false
        let group = sets.filter { $0.isWarmup == isWarmup }
        return ExercisePosition(
            completed: group.fullyCompletedPairedSetCount,
            total: group.pairedSetCount,
            isWarmup: isWarmup
        )
    }

    /// The index the activity should describe: `requested`, unless that exercise is finished and a
    /// later one still has an incomplete set, in which case the first such later exercise.
    ///
    /// A finished exercise has no target set, and a banner with no target has no way forward once
    /// its rest ends. Callers that push after logging a set already advance, but the rest-end push
    /// reuses whatever index it last saw, so the guard lives here where every state is built.
    static func exerciseIndexWithWorkLeft(from requested: Int, in session: WorkoutSessionModel) -> Int {
        let exercises = session.exercises
        guard exercises.indices.contains(requested) else { return requested }
        let hasWorkLeft = { (exercise: WorkoutExerciseModel) in
            exercise.sets.contains { $0.completedAt == nil }
        }
        guard !hasWorkLeft(exercises[requested]) else { return requested }
        return exercises.indices.dropFirst(requested + 1).first { hasWorkLeft(exercises[$0]) } ?? requested
    }

    private func deriveCurrentExerciseData(session: WorkoutSessionModel, index: Int) -> CurrentExerciseData {
        let totalExercisesCount = session.exercises.count
        let currentExercise: WorkoutExerciseModel? =
            (0..<totalExercisesCount).contains(index)
            ? session.exercises[index]
            : nil

        let currentExerciseName = currentExercise?.name
        let currentExerciseImageName = currentExercise?.imageName

        let currentExerciseSets = currentExercise?.sets ?? []
        // "Set n of m" is the set the user is on, so a pair counts as done only once both halves
        // are; see `fullyCompletedPairedSetCount` in WorkoutSetPairing.
        let targetSet = currentExerciseSets.first { $0.completedAt == nil }

        return CurrentExerciseData(
            name: currentExerciseName,
            imageName: currentExerciseImageName,
            position: Self.exercisePosition(in: currentExerciseSets),
            targetSet: targetSet
        )
    }

}

#else
@Observable
class LiveActivityManager: LiveActivityUpdating {
    private(set) var isLiveActivityActive: Bool = false
    
    func updateLiveActivity(params: LiveActivityUpdateParams) { }

    func endLiveActivity(session: WorkoutSessionModel, isCompleted: Bool = true) { }

    func ensureLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool = true,
        currentExerciseIndex: Int = 0,
        restEndsAt: Date? = nil
    ) { }

    func updateRestAndActive(isActive: Bool, restEndsAt: Date?) { }
}

#endif

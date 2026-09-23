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
    
    init(logger: LogManager) {
        self.logger = logger
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
    ///   - statusMessage: Optional status string (e.g. "Resting", "Ready")
    func ensureLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool = true,
        currentExerciseIndex: Int = 0,
        restEndsAt: Date? = nil,
        statusMessage: String? = nil
    ) {
        // Attempt to find an existing activity for this session
        if let existing = existingActivity(for: session.id) {
            currentActivity = existing
            updateLiveActivity(
                params: LiveActivityUpdateParams(
                    session: session,
                    isActive: isActive,
                    currentExerciseIndex: currentExerciseIndex,
                    restEndsAt: restEndsAt,
                    statusMessage: statusMessage,
                    totalVolumeKg: nil,
                    elapsedTime: nil
                )
            )
            return
        }

        // Otherwise start a new live activity
        self.startLiveActivity(
            session: session,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndsAt,
            statusMessage: statusMessage
        )
    }

    /// Ensure a Workout Live Activity using data from the given session
    /// - Parameters:
    ///   - session: WorkoutSessionModel
    ///   - isActive: Bool
    ///   - currentExerciseIndex: Int
    ///   - restEndsAt: Date?
    ///   - statusMessage: String?
    ///   - totalVolumeKg: Double?
    ///   - elapsedTime: TimeInterval?
    func updateLiveActivity(params: LiveActivityUpdateParams) {
        // No Start here: this only builds the content state and hands it to the private overload,
        // which logs the attempt. Tracking in both counted every update twice.
        let updatedState = makeContentState(
            params: MakeContentStateParams(
                session: params.session,
                isActive: params.isActive,
                currentExerciseIndex: params.currentExerciseIndex,
                restEndsAt: params.restEndsAt,
                statusMessage: params.statusMessage,
                totalVolumeKgOverride: params.totalVolumeKg,
                elapsedTimeOverride: params.elapsedTime
            )
        )
        
        self.updateLiveActivity(contentState: updatedState)
    }
    
    /// Ensure a Workout Live Activity using data from the given session
    /// - Parameters:
    ///   - session: WorkoutSessionModel
    ///   - isCompleted: Bool
    ///   - statusMessage: String?
    func endLiveActivity(session: WorkoutSessionModel, isCompleted: Bool = true, statusMessage: String? = nil) {
        logger.trackEvent(event: Event.endLiveActivityStart)
        let message = statusMessage ?? (isCompleted ? "Workout completed" : "Workout ended")
        
        // Build final state with summary metrics if completed
        var finalState = makeContentState(
            params: MakeContentStateParams(
                session: session,
                statusMessage: message,
                elapsedTimeOverride: Date().timeIntervalSince(session.dateCreated)
            )
        )
        
        // Update ended flags
        finalState.isWorkoutEnded = true
        finalState.endedSuccessfully = isCompleted
        
        // Add summary metrics for completed workouts
        if isCompleted {
            let elapsedTime = Date().timeIntervalSince(session.dateCreated)
            let allSets = session.exercises.flatMap { $0.sets }
            // Sets pair; volume does not — both sides of a set are real work lifted.
            let completedSetsCount = session.exercises.reduce(0) {
                $0 + $1.sets.filter { $0.completedAt != nil }.pairedSetCount
            }
            let totalVolume = allSets.compactMap { set -> Double? in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }.reduce(0.0, +)
            
            finalState.finalDurationSeconds = elapsedTime
            finalState.finalVolumeKg = totalVolume > 0 ? totalVolume : nil
            finalState.finalCompletedSetsCount = completedSetsCount
            finalState.finalTotalExercisesCount = session.exercises.count
        }
        
        lastContentState = finalState
        
        // Use different dismissal policies based on completion state
        let dismissalPolicy: ActivityUIDismissalPolicy = isCompleted ? .default : .immediate

        Task {
            await self.endActivity(with: finalState, dismissalPolicy: dismissalPolicy)
            logger.trackEvent(event: Event.endLiveActivitySuccess)
        }
    }
    
    private func endActivity(with finalState: WorkoutActivityAttributes.ContentState, dismissalPolicy: ActivityUIDismissalPolicy) async {
        guard let activity = currentActivity else {
            return
        }
        
        Task {
            await activity.end(
                ActivityContent(
                    state: finalState,
                    staleDate: nil
                ),
                dismissalPolicy: dismissalPolicy
            )
        }
    }

    /// Start a Workout Live Activity using data from the given session
    /// - Parameters:
    ///   - session: The workout session used to seed immutable attributes
    ///   - isActive: Whether the workout timer is running
    ///   - currentExerciseIndex: Index of the currently focused exercise in the session
    ///   - restEndsAt: Optional rest countdown end time
    ///   - statusMessage: Optional status string (e.g. "Resting", "Ready")
    private func startLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool = true,
        currentExerciseIndex: Int = 0,
        restEndsAt: Date? = nil,
        statusMessage: String? = nil
    ) {
        logger.trackEvent(event: Event.startLiveActivityStart)

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.trackEvent(event: Event.liveActivitiesNotEnabled)
            return
        }

        // Reuse an existing activity if present (e.g. after app launch)
        if let existing = firstExistingActivity() {
            self.currentActivity = existing
            observeActivity(activity: existing)
            return
        }

        do {
            let (attributes, initialState) = buildAttributesAndInitialState(
                session: session,
                isActive: isActive,
                currentExerciseIndex: currentExerciseIndex,
                restEndsAt: restEndsAt,
                statusMessage: statusMessage
            )
            try requestAndSetupActivity(attributes: attributes, initialState: initialState)
            logger.trackEvent(event: Event.startLiveActivitySuccess)
        } catch {
            logger.trackEvent(event: Event.startLiveActivityFail(error: error))
        }
    }
    
    private func updateLiveActivity(contentState: WorkoutActivityAttributes.ContentState) {
        // Only update if meaningful changes occurred. A skipped no-op is not an attempt, so the
        // Start belongs below the guard — logging it above gave every unchanged tick a Start with
        // no terminal event and buried the real failures.
        guard shouldUpdateLiveActivity(contentState: contentState) else { return }

        logger.trackEvent(event: Event.updateLiveActivityStart)
        self.lastContentState = contentState

        // Guard activity existence and acceptable state to avoid runtime errors
        guard let activity = self.currentActivity,
              activity.activityState == .active ||
                activity.activityState == .stale else {
            // The activity was dismissed or ended under us. This used to fall out of the `if` with
            // nothing logged, so a Live Activity that stopped updating mid-workout was invisible.
            logger.trackEvent(event: Event.updateLiveActivityFail(error: LiveActivityError.noUpdatableActivity))
            return
        }

        Task {
            await activity.update(ActivityContent(state: contentState, staleDate: contentState.restEndsAt))
            logger.trackEvent(event: Event.updateLiveActivitySuccess)
        }
    }
        
    /// Any difference is worth a push. This used to compare four fields, which was enough while
    /// only those changed between pushes; the reps correction changes `lastLoggedReps` and nothing
    /// else, and a four-field gate dropped it on the floor. The per-second tick still produces an
    /// identical state (elapsed time is not part of it), so the gate keeps that quiet.
    private func shouldUpdateLiveActivity(contentState: WorkoutActivityAttributes.ContentState) -> Bool {
        lastContentState != contentState
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
        restEndsAt: Date?,
        statusMessage: String?
    ) -> (WorkoutActivityAttributes, WorkoutActivityAttributes.ContentState) {
        let attributes = WorkoutActivityAttributes(
            sessionId: session.id,
            workoutName: session.name,
            startedAt: session.dateCreated,
            workoutTemplateId: session.workoutTemplateId
        )
        let initialState = makeContentState(
            params: MakeContentStateParams(
                session: session,
                isActive: isActive,
                currentExerciseIndex: currentExerciseIndex,
                restEndsAt: restEndsAt,
                statusMessage: statusMessage,
                totalVolumeKgOverride: nil,
                elapsedTimeOverride: nil
            )
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

    private func firstExistingActivity() -> Activity<WorkoutActivityAttributes>? {
        Activity<WorkoutActivityAttributes>.activities.first
    }

    private func existingActivity(for sessionId: String) -> Activity<WorkoutActivityAttributes>? {
        Activity<WorkoutActivityAttributes>
            .activities
            .first {
                $0.attributes.sessionId == sessionId && $0.activityState == .active }
    }

    struct MakeContentStateParams {
        let session: WorkoutSessionModel
        let isActive: Bool
        let currentExerciseIndex: Int
        let restEndsAt: Date?
        let statusMessage: String?
        let totalVolumeKgOverride: Double?
        let elapsedTimeOverride: TimeInterval?
        
        init(
            session: WorkoutSessionModel,
            isActive: Bool = false,
            currentExerciseIndex: Int = 0,
            restEndsAt: Date? = nil,
            statusMessage: String? = nil,
            totalVolumeKgOverride: Double? = nil,
            elapsedTimeOverride: TimeInterval? = nil
        ) {
            self.session = session
            self.isActive = isActive
            self.currentExerciseIndex = currentExerciseIndex
            self.restEndsAt = restEndsAt
            self.statusMessage = statusMessage
            self.totalVolumeKgOverride = totalVolumeKgOverride
            self.elapsedTimeOverride = elapsedTimeOverride
        }
    }

    func makeContentState(params: MakeContentStateParams) -> WorkoutActivityAttributes.ContentState {
        
        let totals = computeTotals(session: params.session, totalVolumeKgOverride: params.totalVolumeKgOverride)
        let currentExerciseIndex = Self.exerciseIndexWithWorkLeft(from: params.currentExerciseIndex, in: params.session)
        let current = deriveCurrentExerciseData(session: params.session, index: currentExerciseIndex)
        let next = deriveNextExerciseData(session: params.session, index: currentExerciseIndex)
        // The correction window is exactly the rest that follows a logged set (spec §4). Deriving
        // it from the rest rather than storing it is what clears it when the rest ends: the state
        // is rebuilt on every update, so there is no bookkeeping to get wrong.
        let lastLogged = isResting(restEndsAt: params.restEndsAt) ? lastCompletedSet(session: params.session) : nil

        return WorkoutActivityAttributes.ContentState(
            isActive: params.isActive,
            completedSetsCount: totals.completedSetsCount,
            totalSetsCount: totals.totalSetsCount,
            currentExerciseName: current.name,
            currentExerciseImageName: current.imageName,
            currentExerciseIndex: currentExerciseIndex,
            totalExercisesCount: params.session.exercises.count,
            currentExerciseCompletedSetsCount: current.position.completed,
            currentExerciseTotalSetsCount: current.position.total,
            targetIsWarmup: current.position.isWarmup,
            targetSetId: current.targetSet?.id,
            targetWeightKg: current.targetSet?.weightKg,
            targetReps: current.targetSet?.reps,
            targetDistanceMeters: current.targetSet?.distanceMeters,
            targetDurationSec: current.targetSet?.durationSec,
            restEndsAt: params.restEndsAt,
            statusMessage: params.statusMessage,
            totalVolumeKg: totals.totalVolumeKg,
            progress: totals.progress,
            isWorkoutEnded: false,
            endedSuccessfully: nil,
            finalDurationSeconds: nil,
            finalVolumeKg: nil,
            finalCompletedSetsCount: nil,
            finalTotalExercisesCount: nil,
            isProcessingIntent: false,
            lastIntentTimestamp: nil,
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

    /// Update only isActive/rest/status from current content state to avoid recomputing set counts
    func updateRestAndActive(
        isActive: Bool,
        restEndsAt: Date?,
        statusMessage: String? = nil
    ) {
        Task { @MainActor in
            guard let activity = self.currentActivity else { return }
            // Start from existing content state to preserve counts and progress
            let previous = self.lastContentState
            let newState = WorkoutActivityAttributes.ContentState(
                isActive: isActive,
                completedSetsCount: previous?.completedSetsCount ?? 0,
                totalSetsCount: previous?.totalSetsCount ?? 0,
                currentExerciseName: previous?.currentExerciseName,
                currentExerciseImageName: previous?.currentExerciseImageName,
                currentExerciseIndex: previous?.currentExerciseIndex ?? 0,
                totalExercisesCount: previous?.totalExercisesCount ?? 0,
                currentExerciseCompletedSetsCount: previous?.currentExerciseCompletedSetsCount ?? 0,
                currentExerciseTotalSetsCount: previous?.currentExerciseTotalSetsCount ?? 0,
                targetIsWarmup: previous?.targetIsWarmup ?? false,
                targetSetId: previous?.targetSetId,
                targetWeightKg: previous?.targetWeightKg,
                targetReps: previous?.targetReps,
                targetDistanceMeters: previous?.targetDistanceMeters,
                targetDurationSec: previous?.targetDurationSec,
                restEndsAt: restEndsAt,
                statusMessage: statusMessage ?? previous?.statusMessage,
                totalVolumeKg: previous?.totalVolumeKg,
                progress: previous?.progress ?? 0,
                isWorkoutEnded: false,
                endedSuccessfully: nil,
                finalDurationSeconds: nil,
                finalVolumeKg: nil,
                finalCompletedSetsCount: nil,
                finalTotalExercisesCount: nil,
                isProcessingIntent: false,
                lastIntentTimestamp: nil,
                isAllSetsComplete: previous?.isAllSetsComplete ?? false,
                lastLoggedSetId: previous?.lastLoggedSetId,
                lastLoggedReps: previous?.lastLoggedReps,
                lastLoggedWeightKg: previous?.lastLoggedWeightKg,
                nextExerciseName: previous?.nextExerciseName,
                nextExerciseFirstTargetWeightKg: previous?.nextExerciseFirstTargetWeightKg,
                nextExerciseFirstTargetReps: previous?.nextExerciseFirstTargetReps,
                nextExerciseFirstTargetDistanceMeters: previous?.nextExerciseFirstTargetDistanceMeters,
                nextExerciseFirstTargetDurationSec: previous?.nextExerciseFirstTargetDurationSec
            )
            // Reflect locally and push update with staleDate aligned to rest end
            self.lastContentState = newState
            await activity.update(
                ActivityContent(
                    state: newState,
                    staleDate: restEndsAt,
                    relevanceScore: 100
                )
            )
        }
    }

    // MARK: - Derived state helpers
    private struct Totals {
        let totalSetsCount: Int
        let completedSetsCount: Int
        let totalVolumeKg: Double?
        let progress: Double
        let isAllSetsComplete: Bool
    }

    private func computeTotals(session: WorkoutSessionModel, totalVolumeKgOverride: Double?) -> Totals {
        let allSets = session.exercises.flatMap { $0.sets }
        // Sets pair; volume does not — both sides of a set are real work lifted.
        let totalSetsCount = session.exercises.reduce(0) { $0 + $1.sets.pairedSetCount }
        let completedSetsCount = session.exercises.reduce(0) {
            $0 + $1.sets.filter { $0.completedAt != nil }.pairedSetCount
        }
        let progress = totalSetsCount > 0 ? Double(completedSetsCount) / Double(totalSetsCount) : 0

        let computedVolume = allSets
            .compactMap { set -> Double? in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            .reduce(0.0, +)
        let totalVolumeKg = totalVolumeKgOverride ?? (computedVolume > 0 ? computedVolume : nil)
        let isAllSetsComplete = totalSetsCount > 0 && completedSetsCount == totalSetsCount

        return Totals(
            totalSetsCount: totalSetsCount,
            completedSetsCount: completedSetsCount,
            totalVolumeKg: totalVolumeKg,
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
            completed: fullyCompletedRows(in: group).pairedSetCount,
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

    /// The completed rows of an exercise, leaving out either half of a pair whose other half is
    /// not done. The tracker lets the user tick the right side first, so both sides are checked.
    static func fullyCompletedRows(in sets: [WorkoutSetModel]) -> [WorkoutSetModel] {
        sets.filter { row in
            guard row.completedAt != nil else { return false }
            let pair = sets.pairedSetIds(for: row.id)
            guard pair.count == 2,
                  let partnerId = pair.first(where: { $0 != row.id }),
                  let partner = sets.first(where: { $0.id == partnerId }) else { return true }
            return partner.completedAt != nil
        }
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
        // are. `pairedSetCount` alone reads a lone left row as a finished set, which puts the banner
        // on "Set 2 of 4" while the right arm of set 1 is still to come, and on "Set 5 of 4" at the
        // end. The whole-workout totals keep the plain count on purpose; see WorkoutSetPairing.
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
    
    func startLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool = true,
        currentExerciseIndex: Int = 0,
        restEndsAt: Date? = nil,
        statusMessage: String? = nil
    ) { }

    func updateLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?,
        statusMessage: String? = nil,
        totalVolumeKg: Double? = nil,
        elapsedTime: TimeInterval? = nil
    ) { }

    func endLiveActivity(
        session: WorkoutSessionModel,
        isCompleted: Bool = true,
        statusMessage: String? = nil
    ) { }

    func ensureLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool = true,
        currentExerciseIndex: Int = 0,
        restEndsAt: Date? = nil,
        statusMessage: String? = nil
    ) { }

    func updateRestAndActive(
        isActive: Bool,
        restEndsAt: Date?,
        statusMessage: String? = nil
    ) { }
}

#endif

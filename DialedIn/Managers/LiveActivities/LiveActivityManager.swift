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
    
    var activityViewState: ActivityViewState?
    
	// The currently active Workout Live Activity
	private var currentActivity: Activity<WorkoutActivityAttributes>?
	
	// Cache the last content state to avoid unnecessary updates
	private var lastContentState: WorkoutActivityAttributes.ContentState?
    
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
        logger.trackEvent(event: Event.updateLiveActivityStart)
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
    
    /// Discard the currently active Live Activity
    func discardLiveActivity() async {
        await currentActivity?.end(nil, dismissalPolicy: .immediate)
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
            let completedSetsCount = allSets.filter { $0.completedAt != nil }.count
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
    
    func endActivity(with finalState: WorkoutActivityAttributes.ContentState, dismissalPolicy: ActivityUIDismissalPolicy) async {
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
            self.setup(withActivity: existing)
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
        logger.trackEvent(event: Event.updateLiveActivityStart)
        // Only update if meaningful changes occurred
        guard shouldUpdateLiveActivity(contentState: contentState) else { return }
        
        self.lastContentState = contentState

        // Guard activity existence and acceptable state to avoid runtime errors
        if let activity = self.currentActivity,
           activity.activityState == .active ||
            activity.activityState == .stale {
            Task {
                await activity.update(ActivityContent(state: contentState, staleDate: contentState.restEndsAt))
                logger.trackEvent(event: Event.updateLiveActivitySuccess)
            }
        }
    }
        
    private func shouldUpdateLiveActivity(contentState: WorkoutActivityAttributes.ContentState) -> Bool {
        lastContentState == nil ||
            lastContentState?.currentExerciseIndex != contentState.currentExerciseIndex ||
            lastContentState?.completedSetsCount != contentState.completedSetsCount ||
            lastContentState?.isActive != contentState.isActive ||
            lastContentState?.restEndsAt != contentState.restEndsAt
    }
    
    private func setup(withActivity activity: Activity<WorkoutActivityAttributes>) {
        self.activityViewState = .init(
            activityState: activity.activityState,
            contentState: activity.content.state,
            pushToken: activity.pushToken?.hexadecimalString
        )
        observeActivity(activity: activity)
    }
    
    private func observeActivity(activity: Activity<WorkoutActivityAttributes>) {
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { @MainActor @Sendable in
                    for await activityState in activity.activityStateUpdates {
                        if activityState == .dismissed {
                            self.cleanupDismissedActivity()
                        } else {
                            self.activityViewState?.activityState = activityState
                        }
                    }
                }
                
                group.addTask { @MainActor @Sendable in
                    for await contentState in activity.contentUpdates {
                        self.activityViewState?.contentState = contentState.state
                    }
                }
            }
        }
    }
        
    private func cleanupDismissedActivity() {
        self.currentActivity = nil
        self.activityViewState = nil
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
            pushType: .token
        )
        self.currentActivity = activity
        self.setup(withActivity: activity)
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

    private struct MakeContentStateParams {
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

    private func makeContentState(params: MakeContentStateParams) -> WorkoutActivityAttributes.ContentState {
        
        let totals = computeTotals(session: params.session, totalVolumeKgOverride: params.totalVolumeKgOverride)
        let current = deriveCurrentExerciseData(session: params.session, index: params.currentExerciseIndex)

        return WorkoutActivityAttributes.ContentState(
            isActive: params.isActive,
            completedSetsCount: totals.completedSetsCount,
            totalSetsCount: totals.totalSetsCount,
            currentExerciseName: current.name,
            currentExerciseImageName: current.imageName,
            currentExerciseIndex: params.currentExerciseIndex,
            totalExercisesCount: params.session.exercises.count,
            currentExerciseCompletedSetsCount: current.currentExerciseCompletedSetsCount,
            currentExerciseTotalSetsCount: current.currentExerciseTotalSetsCount,
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
            isAllSetsComplete: totals.isAllSetsComplete
        )
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
            let previous = self.activityViewState?.contentState
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
                isAllSetsComplete: previous?.isAllSetsComplete ?? false
            )
            // Reflect locally and push update with staleDate aligned to rest end
            self.activityViewState?.contentState = newState
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
        let totalSetsCount = allSets.count
        let completedSetsCount = allSets.filter { $0.completedAt != nil }.count
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

    private struct CurrentExerciseData {
        let name: String?
        let imageName: String?
        let currentExerciseCompletedSetsCount: Int
        let currentExerciseTotalSetsCount: Int
        let targetSet: WorkoutSetModel?
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
        let currentExerciseCompletedSetsCount = currentExerciseSets.filter { $0.completedAt != nil }.count
        let currentExerciseTotalSetsCount = currentExerciseSets.count
        let targetSet = currentExercise?.sets.first { $0.completedAt == nil }

        return CurrentExerciseData(
            name: currentExerciseName,
            imageName: currentExerciseImageName,
            currentExerciseCompletedSetsCount: currentExerciseCompletedSetsCount,
            currentExerciseTotalSetsCount: currentExerciseTotalSetsCount,
            targetSet: targetSet
        )
    }

}

// MARK: Events
extension LiveActivityManager {
    enum Event: LoggableEvent {
        case startLiveActivityStart
        case startLiveActivitySuccess
        case startLiveActivityFail(error: Error)
        case liveActivitiesNotEnabled
        case updateLiveActivityStart
        case updateLiveActivitySuccess
        case updateLiveActivityFail(error: Error)
        case endLiveActivityStart
        case endLiveActivitySuccess

        var eventName: String {
            switch self {
            case .startLiveActivityStart:       return "LiveActivityMan_StartLiveActiviey_Start"
            case .startLiveActivitySuccess:     return "LiveActivityMan_StartLiveActiviey_Success"
            case .startLiveActivityFail:        return "LiveActivityMan_StartLiveActiviey_Fail"
            case .liveActivitiesNotEnabled:     return "LiveActivityMan_LiveActivitiesNotEnabled"
            case .updateLiveActivityStart:      return "LiveActivityMan_UpdateLiveActivity_Start"
            case .updateLiveActivitySuccess:    return "LiveActivityMan_UpdateLiveActivity_Success"
            case .updateLiveActivityFail:       return "LiveActivityMan_UpdateLiveActivity_Fail"
            case .endLiveActivityStart:         return "LiveActivityMan_EndLiveActivity_Start"
            case .endLiveActivitySuccess:       return "LiveActivityMan_EndLiveActivity_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .startLiveActivityFail(error: let error), .updateLiveActivityFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .startLiveActivityFail, .updateLiveActivityFail:
                return .severe
            default:
                return .analytic
            }
        }
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
private extension Data {
    var hexadecimalString: String {
        self.reduce("") {
            $0 + String(format: "%02x", $1)
        }
    }
}

// The state model for keeping track of the widget's current state
struct ActivityViewState: Sendable {
    var activityState: ActivityState
    var contentState: WorkoutActivityAttributes.ContentState
    var pushToken: String?
    
    // End the widget state controls.
    var shouldShowEndControls: Bool {
        switch activityState {
        case .active, .stale:
            return true
        default:
            return false
        }
    }
    
    var updateControlDisabled: Bool = false
    
    // Update the widget state controls
    var shouldShowUpdateControls: Bool {
        switch activityState {
        case .active, .stale:
            return true
        default:
            return false
        }
    }
    
    var isStale: Bool {
        return activityState == .stale
    }
}

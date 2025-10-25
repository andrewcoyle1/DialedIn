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
    
    // Track active state internally instead of setting it on HKWorkoutManager
    private(set) var isLiveActivityActive: Bool = false
    
    init() {
        // No circular reference setup needed
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
            case .ended, .dismissed:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        }
        
        var updateControlDisabled: Bool = false
        
        // Update the widget state controls
        var shouldShowUpdateControls: Bool {
            switch activityState {
            case .active, .stale:
                return true
            case .ended, .pending:
                return false
            case .dismissed:
                return false
            @unknown default:
                return false
            }
        }
        
        var isStale: Bool {
            return activityState == .stale
        }
    }
    
    var activityViewState: ActivityViewState?
    
	// The currently active Workout Live Activity
	private var currentActivity: Activity<WorkoutActivityAttributes>?
	
	// Cache the last content state to avoid unnecessary updates
	private var lastContentState: WorkoutActivityAttributes.ContentState?

	// MARK: - Public API

	/// Start a Workout Live Activity using data from the given session
	/// - Parameters:
	///   - session: The workout session used to seed immutable attributes
	///   - isActive: Whether the workout timer is running
	///   - currentExerciseIndex: Index of the currently focused exercise in the session
	///   - restEndsAt: Optional rest countdown end time
	///   - statusMessage: Optional status string (e.g. "Resting", "Ready")
	func startLiveActivity(
		session: WorkoutSessionModel,
		isActive: Bool = true,
		currentExerciseIndex: Int = 0,
		restEndsAt: Date? = nil,
		statusMessage: String? = nil
	) {
        
        let areActivitiesEnabled = ActivityAuthorizationInfo().areActivitiesEnabled
        
        if areActivitiesEnabled {
            // Reuse an existing activity if present (e.g. after app launch)
            let existingActivities = Activity<WorkoutActivityAttributes>.activities
            
            if let existing = existingActivities.first {
                self.currentActivity = existing
                self.setup(withActivity: existing)
                isLiveActivityActive = true
                return
            }
                        
            do {
                let attributes = WorkoutActivityAttributes(
                    sessionId: session.id,
                    workoutName: session.name,
                    startedAt: session.dateCreated,
                    workoutTemplateId: session.workoutTemplateId
                )
                
                let initialState = makeContentState(
                    for: session,
                    isActive: isActive,
                    currentExerciseIndex: currentExerciseIndex,
                    restEndsAt: restEndsAt,
                    statusMessage: statusMessage,
                    totalVolumeKgOverride: nil,
                    elapsedTimeOverride: nil
                )
                
                lastContentState = initialState
                
                let activity = try Activity.request(
                    attributes: attributes,
                    content: ActivityContent(state: initialState, staleDate: nil),
                    pushType: .token
                )
                
                self.currentActivity = activity
                self.setup(withActivity: activity)
                isLiveActivityActive = true
            } catch {
                isLiveActivityActive = false
            }
        } else {
            
        }
	}

    /// Ensure a Workout Live Activity exists for this session; if found, reuse and update it, otherwise create it
    func ensureLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool = true,
        currentExerciseIndex: Int = 0,
        restEndsAt: Date? = nil,
        statusMessage: String? = nil
    ) {
        // Attempt to find an existing activity for this session
        if let existing = Activity<WorkoutActivityAttributes>.activities.first(where: { activity in
            activity.attributes.sessionId == session.id && activity.activityState == .active
        }) {
            currentActivity = existing
            updateLiveActivity(
                session: session,
                isActive: isActive,
                currentExerciseIndex: currentExerciseIndex,
                restEndsAt: restEndsAt,
                statusMessage: statusMessage,
                totalVolumeKg: nil,
                elapsedTime: nil
            )
            return
        }
        
        // Otherwise start a new live activity
        startLiveActivity(
            session: session,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndsAt,
            statusMessage: statusMessage
        )
    }

	/// Update the Workout Live Activity with latest session progress
	func updateLiveActivity(
		session: WorkoutSessionModel,
		isActive: Bool,
		currentExerciseIndex: Int,
		restEndsAt: Date?,
		statusMessage: String? = nil,
		totalVolumeKg: Double? = nil,
		elapsedTime: TimeInterval? = nil
	) {
        let updatedState = makeContentState(
			for: session,
			isActive: isActive,
			currentExerciseIndex: currentExerciseIndex,
			restEndsAt: restEndsAt,
			statusMessage: statusMessage,
			totalVolumeKgOverride: totalVolumeKg,
			elapsedTimeOverride: elapsedTime
		)
		
		// Only update if meaningful changes occurred
		let shouldUpdate = lastContentState == nil ||
			lastContentState?.currentExerciseIndex != updatedState.currentExerciseIndex ||
			lastContentState?.completedSetsCount != updatedState.completedSetsCount ||
			lastContentState?.isActive != updatedState.isActive ||
			lastContentState?.restEndsAt != updatedState.restEndsAt
		
		guard shouldUpdate else { return }
		
		lastContentState = updatedState

        Task { @MainActor in
            defer {
                self.activityViewState?.updateControlDisabled = false
            }
            self.activityViewState?.updateControlDisabled = true
            // Guard activity existence and acceptable state to avoid runtime errors
            if let activity = self.currentActivity,
               activity.activityState == .active || activity.activityState == .stale {
                do {
                    try await self.updateWorkoutActivity(with: updatedState)
                } catch {
                    print("⚠️ Failed to update Live Activity: \(error)")
                    // Clean up if the activity is in an invalid state
                    if activity.activityState == .dismissed || activity.activityState == .ended {
                        self.cleanupDismissedActivity()
                    }
                }
            } else {
                // No-op if activity is missing or ended/dismissed
                self.activityViewState?.updateControlDisabled = false
            }
        }
	}

	/// End the Workout Live Activity
	func endLiveActivity(
		session: WorkoutSessionModel,
		isCompleted: Bool = true,
		statusMessage: String? = nil
	) {
		let message = statusMessage ?? (isCompleted ? "Workout completed" : "Workout ended")
		
		// Build final state with summary metrics if completed
		var finalState = makeContentState(
			for: session,
			isActive: false,
			currentExerciseIndex: 0,
			restEndsAt: nil,
			statusMessage: message,
			totalVolumeKgOverride: nil,
			elapsedTimeOverride: Date().timeIntervalSince(session.dateCreated)
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

        Task { @MainActor in
            await self.endActivity(with: finalState, dismissalPolicy: dismissalPolicy)
        }
	}
}

extension LiveActivityManager {
    
    func endActivity(with finalState: WorkoutActivityAttributes.ContentState, dismissalPolicy: ActivityUIDismissalPolicy) async {
        guard let activity = currentActivity else {
            return
        }
        
        isLiveActivityActive = false
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
    
    func setup(withActivity activity: Activity<WorkoutActivityAttributes>) {
        self.activityViewState = .init(
            activityState: activity.activityState,
            contentState: activity.content.state,
            pushToken: activity.pushToken?.hexadecimalString
        )
        observeActivity(activity: activity)
    }
    
    func observeActivity(activity: Activity<WorkoutActivityAttributes>) {
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
    
    func updateWorkoutActivity(with updatedState: WorkoutActivityAttributes.ContentState) async throws {
        guard let activity = currentActivity else {
            return
        }
        
        let contentState: WorkoutActivityAttributes.ContentState
        
        contentState = updatedState
        await activity.update(
            ActivityContent(
                state: contentState,
                staleDate: contentState.restEndsAt,
                relevanceScore: 100
            )
        )
    }
    
    func cleanupDismissedActivity() {
        self.currentActivity = nil
        self.activityViewState = nil
        self.lastContentState = nil
        self.isLiveActivityActive = false
    }
    
    // MARK: - Helpers
    // swiftlint:disable:next function_parameter_count
    private func makeContentState(
        for session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?,
        statusMessage: String?,
        totalVolumeKgOverride: Double?,
        elapsedTimeOverride: TimeInterval?
    ) -> WorkoutActivityAttributes.ContentState {
        let totals = computeTotals(session: session, totalVolumeKgOverride: totalVolumeKgOverride)
        let current = deriveCurrentExerciseData(session: session, index: currentExerciseIndex)
        logExerciseImageChange(current.imageName, currentExerciseIndex: currentExerciseIndex, exerciseName: current.name)

        return WorkoutActivityAttributes.ContentState(
            isActive: isActive,
            completedSetsCount: totals.completedSetsCount,
            totalSetsCount: totals.totalSetsCount,
            currentExerciseName: current.name,
            currentExerciseImageName: current.imageName,
            currentExerciseIndex: currentExerciseIndex,
            totalExercisesCount: session.exercises.count,
            currentExerciseCompletedSetsCount: current.currentExerciseCompletedSetsCount,
            currentExerciseTotalSetsCount: current.currentExerciseTotalSetsCount,
            targetSetId: current.targetSet?.id,
            targetWeightKg: current.targetSet?.weightKg,
            targetReps: current.targetSet?.reps,
            targetDistanceMeters: current.targetSet?.distanceMeters,
            targetDurationSec: current.targetSet?.durationSec,
            restEndsAt: restEndsAt,
            statusMessage: statusMessage,
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

    private func logExerciseImageChange(_ imageName: String?, currentExerciseIndex: Int, exerciseName: String?) {
        guard imageName != lastContentState?.currentExerciseImageName else { return }
        if let imageName {
            print("📸 Live Activity: Exercise image changed to '\(imageName)' (index: \(currentExerciseIndex), name: \(exerciseName ?? "nil"))")
        } else {
            print("⚠️ Live Activity: No image for current exercise (index: \(currentExerciseIndex))")
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

private extension Data {
    var hexadecimalString: String {
        self.reduce("") {
            $0 + String(format: "%02x", $1)
        }
    }
}

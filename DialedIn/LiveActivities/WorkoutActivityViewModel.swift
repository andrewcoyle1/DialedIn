//
//  WorkoutActivityViewModel.swift
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
class WorkoutActivityViewModel {
    
    private let hkWorkoutManager: HKWorkoutManager
    
    init(hkWorkoutManager: HKWorkoutManager) {
        self.hkWorkoutManager = hkWorkoutManager
        // Set up the circular reference
        hkWorkoutManager.workoutActivityViewModel = self
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
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            // Reuse an existing activity if present (e.g. after app launch)
            if let existing = Activity<WorkoutActivityAttributes>.activities.first {
                self.currentActivity = existing
                self.setup(withActivity: existing)
                hkWorkoutManager.isLiveActivityActive = true
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
                hkWorkoutManager.isLiveActivityActive = true
            } catch {
                print("Error starting workout live activity: \(error)")
                hkWorkoutManager.isLiveActivityActive = false

            }
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
		success: Bool = true,
		statusMessage: String? = nil
	) {
		let message = statusMessage ?? (success ? "Workout completed" : "Workout ended")
		let finalState = makeContentState(
			for: session,
			isActive: false,
			currentExerciseIndex: 0,
			restEndsAt: nil,
			statusMessage: message,
			totalVolumeKgOverride: nil,
			elapsedTimeOverride: Date().timeIntervalSince(session.dateCreated)
		)
		
		lastContentState = finalState

        Task { @MainActor in
            await self.endActivity(with: finalState)
        }
	}
}

extension WorkoutActivityViewModel {
    
    func endActivity(with finalState: WorkoutActivityAttributes.ContentState) async {
        guard let activity = currentActivity else {
            return
        }
        
        let dismissalPolicy: ActivityUIDismissalPolicy = .default
        
        hkWorkoutManager.isLiveActivityActive = false
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
        let totalExercisesCount = session.exercises.count
        let currentExercise: WorkoutExerciseModel? =
            (0..<totalExercisesCount).contains(currentExerciseIndex)
            ? session.exercises[currentExerciseIndex]
            : nil
        
        let currentExerciseName = currentExercise?.name
        let currentExerciseImageName = currentExercise?.imageName
        
        // Only log when image changes
        if currentExerciseImageName != lastContentState?.currentExerciseImageName {
            if let imageName = currentExerciseImageName {
                print("📸 Live Activity: Exercise image changed to '\(imageName)'")
            } else {
                print("⚠️ Live Activity: No image for current exercise")
            }
        }

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

        return WorkoutActivityAttributes.ContentState(
            isActive: isActive,
            completedSetsCount: completedSetsCount,
            totalSetsCount: totalSetsCount,
            currentExerciseName: currentExerciseName,
            currentExerciseImageName: currentExerciseImageName,
            currentExerciseIndex: currentExerciseIndex,
            totalExercisesCount: totalExercisesCount,
            restEndsAt: restEndsAt,
            statusMessage: statusMessage,
            totalVolumeKg: totalVolumeKg,
            progress: progress
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
                restEndsAt: restEndsAt,
                statusMessage: statusMessage ?? previous?.statusMessage,
                totalVolumeKg: previous?.totalVolumeKg,
                progress: previous?.progress ?? 0
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
}

#else
@Observable
class WorkoutActivityViewModel {
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
        success: Bool = true,
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

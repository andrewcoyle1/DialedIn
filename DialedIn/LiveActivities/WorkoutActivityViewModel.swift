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
class WorkoutActivityViewModel {

	// The currently active Workout Live Activity
	var activity: Activity<WorkoutActivityAttributes>?

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

		do {
			activity = try Activity.request(
				attributes: attributes,
				content: ActivityContent(state: initialState, staleDate: nil)
			)
		} catch {
			print("Error starting workout live activity: \(error)")
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
            self.activity = existing
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

		Task {
            await activity?.update(ActivityContent<Activity<WorkoutActivityAttributes>.ContentState>(state: updatedState, staleDate: nil))
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

		Task {
			await activity?.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .default
                // If the live activity should be dismissed/cleared immediately
                // dismissalPolicy: .immediate
			)
		}
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
		let currentExerciseName: String? =
			(0..<totalExercisesCount).contains(currentExerciseIndex)
			? session.exercises[currentExerciseIndex].name
			: nil

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
			currentExerciseIndex: currentExerciseIndex,
			totalExercisesCount: totalExercisesCount,
			restEndsAt: restEndsAt,
			statusMessage: statusMessage,
			totalVolumeKg: totalVolumeKg,
			progress: progress
		)
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
}
#endif

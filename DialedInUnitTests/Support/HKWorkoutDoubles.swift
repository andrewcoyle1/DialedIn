//
//  HKWorkoutDoubles.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 22/09/2026.
//

import Foundation
@testable import DialedIn

#if canImport(HealthKit) && !targetEnvironment(macCatalyst)

/// Records what `HKWorkoutManager` asks of the Live Activity.
///
/// The real `LiveActivityManager` cannot start an `Activity` in a test process, so the only way to
/// see what the manager decided is to stand in for the updater it talks to.
@MainActor
final class LiveActivityUpdaterSpy: LiveActivityUpdating {

    struct RestAndActive: Equatable {
        let isActive: Bool
        let restEndsAt: Date?
    }

    private(set) var ensured: [String] = []
    private(set) var fullUpdates: [LiveActivityUpdateParams] = []
    private(set) var restAndActiveUpdates: [RestAndActive] = []
    private(set) var ended: [String] = []

    func ensureLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?
    ) {
        ensured.append(session.id)
    }

    func updateLiveActivity(params: LiveActivityUpdateParams) {
        fullUpdates.append(params)
    }

    func updateRestAndActive(isActive: Bool, restEndsAt: Date?) {
        restAndActiveUpdates.append(RestAndActive(isActive: isActive, restEndsAt: restEndsAt))
    }

    func endLiveActivity(session: WorkoutSessionModel, isCompleted: Bool) {
        ended.append(session.id)
    }
}

/// Counts `Constants.workoutRestDidComplete` posts.
///
/// The manager announces a finished rest to whichever screen is listening rather than calling it,
/// so the post is the only observable difference between a rest that ran out and one that was
/// cancelled. The count is behind a lock because the notification can be delivered from any queue.
final class RestCompletionSpy: @unchecked Sendable {
    private let lock = NSLock()
    private var posts = 0
    private var token: NSObjectProtocol?

    var count: Int {
        lock.withLock { posts }
    }

    init() {
        token = NotificationCenter.default.addObserver(
            forName: Constants.workoutRestDidComplete,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let self else { return }
            self.lock.withLock { self.posts += 1 }
        }
    }

    deinit {
        if let token {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

#endif

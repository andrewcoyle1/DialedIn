//
//  LiveActivityManagerTests.swift
//  DialedInUnitTests
//

import Testing
import Foundation
@testable import DialedIn

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)

/// The Live Activity updater, seen through what it reports.
///
/// A real `Activity<WorkoutActivityAttributes>` cannot be started in a test process, so the
/// manager here always has none — which is exactly the case that used to fall out of the update
/// silently.
@MainActor
struct LiveActivityManagerTests {

    /// Records what the manager hands the log manager. `LogService` is `Sendable`, so the store
    /// has to be one too.
    private final class SpyLogService: LogService, @unchecked Sendable {
        private let lock = NSLock()
        private var names: [String] = []

        var trackedEventNames: [String] {
            lock.withLock { names }
        }

        func identifyUser(userId: String, name: String?, email: String?) { }
        func addUserProperties(dict: [String: Any], isHighPriority: Bool) { }
        func deleteUserProfile() { }

        func trackEvent(event: LoggableEvent) {
            lock.withLock { names.append(event.eventName) }
        }

        func trackScreenView(event: LoggableEvent) {
            lock.withLock { names.append(event.eventName) }
        }
    }

    private func makeManager() -> (LiveActivityManager, SpyLogService) {
        let spy = SpyLogService()
        return (LiveActivityManager(logger: LogManager(services: [spy])), spy)
    }

    private func params(isActive: Bool = true) -> LiveActivityUpdateParams {
        LiveActivityUpdateParams(
            session: WorkoutSessionModel(
                id: "s1",
                authorId: "author-1",
                name: "Upper",
                dateCreated: Date(timeIntervalSince1970: 1_772_000_000),
                exercises: []
            ),
            isActive: isActive,
            currentExerciseIndex: 0,
            restEndsAt: nil,
            statusMessage: nil,
            totalVolumeKg: nil,
            elapsedTime: nil
        )
    }

    /// With no Live Activity to update, the update fell out of an `if` with nothing logged: a
    /// Start and no terminal event, so a Live Activity that stopped updating mid-workout was
    /// invisible.
    @Test("Test Updating With No Live Activity Reports The Failure")
    func testUpdatingWithNoLiveActivityReportsTheFailure() {
        let (manager, spy) = makeManager()

        manager.updateLiveActivity(params: params())

        #expect(spy.trackedEventNames == [
            "LiveActivityMan_UpdateLiveActivity_Start",
            "LiveActivityMan_UpdateLiveActivity_Fail"
        ])
    }

    /// The public entry point logged a Start and then called the private one, which logged another,
    /// so every update counted twice.
    @Test("Test One Update Reports One Start")
    func testOneUpdateReportsOneStart() {
        let (manager, spy) = makeManager()

        manager.updateLiveActivity(params: params())

        #expect(spy.trackedEventNames.filter { $0 == "LiveActivityMan_UpdateLiveActivity_Start" }.count == 1)
    }

    /// A tick that changes nothing is not an attempt. The Start used to be logged above the
    /// no-op guard, so unchanged ticks filled the funnel with Starts nothing ever answered.
    @Test("Test An Unchanged Update Reports Nothing")
    func testAnUnchangedUpdateReportsNothing() {
        let (manager, spy) = makeManager()
        manager.updateLiveActivity(params: params())
        let afterFirst = spy.trackedEventNames.count

        manager.updateLiveActivity(params: params())

        #expect(spy.trackedEventNames.count == afterFirst)
    }
}

#endif

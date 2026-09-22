//
//  HKWorkoutManagerRestTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 22/09/2026.
//

import Testing
import Foundation
@testable import DialedIn

#if canImport(HealthKit) && !targetEnvironment(macCatalyst)

/// The rest timer that lives on `HKWorkoutManager`.
///
/// No `HKWorkoutSession` can be started in a test process, so everything here is the half of the
/// manager that does not need one: the rest timer, the shared storage it writes for the widget, and
/// the announcement the tracker screen listens for. `state` therefore stays `.notStarted`
/// throughout, which is why every Live Activity update below carries `isActive == false`.
///
/// Serialized because the three things under test — `NotificationCenter.default`, the app group's
/// `UserDefaults`, and the process-wide dispatch queues the rest timer fires on — are all shared,
/// and two of these tests running at once would read each other's posts.
@Suite(.serialized)
@MainActor
struct HKWorkoutManagerRestTests {

    /// Long enough for a timer that should have been cancelled to have fired anyway, short enough
    /// that thirteen tests do not add a minute to the suite. Only spent when the expectation holds.
    private static let slack: Duration = .seconds(1)

    /// A rest that runs out almost immediately. Driving the timer rather than waiting one out is
    /// what keeps these tests off the clock; the fractional seam exists for exactly this.
    private static let briefRest: TimeInterval = 0.05

    private func makeManager() -> (HKWorkoutManager, LiveActivityUpdaterSpy) {
        // Previous runs share the app group with this one, so a rest left behind by a crashed run
        // would otherwise be read back as a rest in progress.
        SharedWorkoutStorage.clearRestEndTime()
        let spy = LiveActivityUpdaterSpy()
        return (HKWorkoutManager(logger: LogManager(), liveActivityUpdater: spy), spy)
    }

    private var session: WorkoutSessionModel {
        WorkoutSessionModel(
            id: "session-1",
            authorId: "author-1",
            name: "Upper",
            dateCreated: Date(timeIntervalSince1970: 1_772_000_000),
            exercises: []
        )
    }

    /// Waits out `slack` and answers whether the rest ever announced itself. Written as a wait for
    /// the thing not to happen, so a test that expects silence spends the whole window.
    private func announced(_ spy: RestCompletionSpy) async -> Bool {
        await TestManagers.eventually(timeout: Self.slack) { spy.count > 0 }
    }

    // MARK: - Starting

    @Test("Test Starting A Rest Sets The End Time")
    func testStartingARestSetsTheEndTime() {
        let (manager, _) = makeManager()
        let before = Date()

        manager.startRest(durationSeconds: 90, session: session)

        let end = manager.restEndTime
        #expect(end != nil)
        #expect((end?.timeIntervalSince(before) ?? 0) >= 90)
        #expect((end?.timeIntervalSince(before) ?? 0) < 95)
    }

    /// The widget reads the countdown out of the app group rather than being handed it, so a rest
    /// the manager knows about and the group does not is a Dynamic Island stuck on the last value.
    @Test("Test Starting A Rest Shares The End Time With The Widget")
    func testStartingARestSharesTheEndTimeWithTheWidget() throws {
        let (manager, _) = makeManager()

        manager.startRest(durationSeconds: 90, session: session)

        let shared = try #require(SharedWorkoutStorage.restEndTime)
        let end = try #require(manager.restEndTime)
        // Shared storage keeps a `timeIntervalSince1970`, so the two are the same instant rather
        // than the same `Date` value.
        #expect(abs(shared.timeIntervalSince(end)) < 0.001)
    }

    @Test("Test Starting A Rest Puts The Countdown On The Live Activity")
    func testStartingARestPutsTheCountdownOnTheLiveActivity() throws {
        let (manager, spy) = makeManager()

        manager.startRest(durationSeconds: 90, session: session, currentExerciseIndex: 3)

        let update = try #require(spy.fullUpdates.last)
        #expect(update.restEndsAt == manager.restEndTime)
        #expect(update.statusMessage == "Resting")
        #expect(update.currentExerciseIndex == 3)
    }

    /// `max(0, …)` guards this. A negative duration would otherwise put the end time in the past,
    /// which reads everywhere else as "not resting" while a timer is still scheduled.
    @Test("Test A Negative Duration Rests For No Time Rather Than Ending In The Past")
    func testANegativeDurationRestsForNoTime() {
        let (manager, _) = makeManager()
        let before = Date()

        manager.startRest(durationSeconds: -30, session: session)

        #expect((manager.restEndTime?.timeIntervalSince(before) ?? -1) >= 0)
    }

    // MARK: - Running Out

    @Test("Test A Rest That Runs Out Announces Itself")
    func testARestThatRunsOutAnnouncesItself() async {
        let (manager, _) = makeManager()
        let posts = RestCompletionSpy()

        manager.startRest(duration: Self.briefRest, session: session)

        #expect(await TestManagers.eventually { posts.count == 1 })
        #expect(manager.restEndTime == nil)
    }

    /// The announcement is what fires the sound and the vibration on the tracker screen, and it is
    /// posted above the Live Activity guards in `endRest` on purpose: a rest that has run out is
    /// over whether or not there is an activity left to redraw.
    @Test("Test A Rest Announces Itself Even With No Live Activity Updater")
    func testARestAnnouncesItselfWithNoLiveActivityUpdater() async {
        SharedWorkoutStorage.clearRestEndTime()
        let manager = HKWorkoutManager(logger: LogManager(), liveActivityUpdater: nil)
        let posts = RestCompletionSpy()

        manager.startRest(duration: Self.briefRest, session: session)

        #expect(await TestManagers.eventually { posts.count == 1 })
    }

    @Test("Test A Rest That Runs Out Clears The Shared Copy")
    func testARestThatRunsOutClearsTheSharedCopy() async {
        let (manager, _) = makeManager()

        manager.startRest(duration: Self.briefRest, session: session)

        #expect(await TestManagers.eventually { SharedWorkoutStorage.restEndTime == nil })
    }

    // MARK: - Cancelling

    /// The distinction the whole feature turns on: a user who cancelled a rest already knows it
    /// ended, so cancelling must not ding them.
    @Test("Test A Cancelled Rest Announces Nothing")
    func testACancelledRestAnnouncesNothing() async {
        let (manager, _) = makeManager()
        let posts = RestCompletionSpy()

        manager.startRest(duration: Self.briefRest, session: session)
        manager.cancelRest()

        #expect(await announced(posts) == false)
    }

    @Test("Test Cancelling Clears The End Time And The Shared Copy")
    func testCancellingClearsTheEndTimeAndTheSharedCopy() {
        let (manager, _) = makeManager()
        manager.startRest(durationSeconds: 90, session: session)
        #expect(manager.restEndTime != nil)

        manager.cancelRest()

        #expect(manager.restEndTime == nil)
        #expect(SharedWorkoutStorage.restEndTime == nil)
    }

    /// `updateRestAndActive` rather than a full update, so the exercise the Live Activity is
    /// showing survives the cancel.
    @Test("Test Cancelling Clears The Countdown Without Redrawing The Exercise")
    func testCancellingClearsTheCountdownWithoutRedrawingTheExercise() throws {
        let (manager, spy) = makeManager()
        manager.startRest(durationSeconds: 90, session: session, currentExerciseIndex: 3)
        let updatesBefore = spy.fullUpdates.count

        manager.cancelRest()

        #expect(spy.restAndActiveUpdates.last?.restEndsAt == nil)
        #expect(spy.restAndActiveUpdates.last?.statusMessage == nil)
        #expect(spy.fullUpdates.count == updatesBefore)
    }

    // MARK: - Replacing

    /// Two live timers would announce the first rest's end in the middle of the second one.
    @Test("Test Starting A Second Rest Replaces The First Rather Than Running Both")
    func testStartingASecondRestReplacesTheFirst() async {
        let (manager, _) = makeManager()
        let posts = RestCompletionSpy()

        manager.startRest(duration: Self.briefRest, session: session)
        manager.startRest(durationSeconds: 90, session: session)

        #expect(await announced(posts) == false)
        #expect((manager.restEndTime?.timeIntervalSinceNow ?? 0) > 60)
    }

    // MARK: - Widget Changes

    /// The widget can extend a rest, and the phone then has to ding at the new time rather than the
    /// old one. The reschedule used to overwrite the stored timer without cancelling it, leaving
    /// the original still scheduled and still able to fire.
    @Test("Test A Rest Extended From The Widget Does Not Announce At The Old Time")
    func testARestExtendedFromTheWidgetDoesNotAnnounceAtTheOldTime() async {
        let (manager, _) = makeManager()
        let posts = RestCompletionSpy()
        manager.startRest(duration: Self.briefRest, session: session)

        SharedWorkoutStorage.restEndTime = Date().addingTimeInterval(3600)
        manager.syncRestEndTimeFromSharedStorage()

        #expect(await announced(posts) == false)
        #expect((manager.restEndTime?.timeIntervalSinceNow ?? 0) > 60)
    }

    @Test("Test A Rest Cleared From The Widget Cancels The Timer")
    func testARestClearedFromTheWidgetCancelsTheTimer() async {
        let (manager, _) = makeManager()
        let posts = RestCompletionSpy()
        manager.startRest(duration: Self.briefRest, session: session)

        SharedWorkoutStorage.clearRestEndTime()
        manager.syncRestEndTimeFromSharedStorage()

        #expect(manager.restEndTime == nil)
        #expect(await announced(posts) == false)
    }

    /// Both sides write the same rest a moment apart, so only a difference worth acting on counts
    /// as a change — otherwise every tick would reschedule the timer.
    @Test("Test A Shared End Time Within Half A Second Is Left Alone")
    func testASharedEndTimeWithinHalfASecondIsLeftAlone() throws {
        let (manager, _) = makeManager()
        manager.startRest(durationSeconds: 90, session: session)
        let end = try #require(manager.restEndTime)

        SharedWorkoutStorage.restEndTime = end.addingTimeInterval(0.2)
        manager.syncRestEndTimeFromSharedStorage()

        #expect(manager.restEndTime == end)
    }

    // MARK: - Workout Lifecycle

    @Test("Test Ending The Workout Cancels The Rest Without Announcing It")
    func testEndingTheWorkoutCancelsTheRestWithoutAnnouncingIt() async {
        let (manager, _) = makeManager()
        let posts = RestCompletionSpy()
        manager.startRest(duration: Self.briefRest, session: session)

        manager.endWorkout()

        #expect(manager.restEndTime == nil)
        #expect(SharedWorkoutStorage.restEndTime == nil)
        #expect(await announced(posts) == false)
    }

    @Test("Test Discarding The Workout Cancels The Rest And Clears The Metrics")
    func testDiscardingTheWorkoutCancelsTheRestAndClearsTheMetrics() async {
        let (manager, _) = makeManager()
        let posts = RestCompletionSpy()
        manager.startRest(duration: Self.briefRest, session: session)
        manager.metrics.elapsedTime = 120
        manager.metrics.heartRate = 140

        manager.discardWorkout()

        #expect(manager.restEndTime == nil)
        #expect(manager.metrics.elapsedTime == 0)
        #expect(manager.metrics.heartRate == nil)
        #expect(await announced(posts) == false)
    }

    /// A rest timer holds the manager only weakly, so a workout that is torn down mid-rest takes
    /// the manager with it rather than leaving it alive until the rest would have ended.
    @Test("Test A Manager Released Mid-Rest Is Deallocated")
    func testAManagerReleasedMidRestIsDeallocated() {
        SharedWorkoutStorage.clearRestEndTime()
        let spy = LiveActivityUpdaterSpy()
        var manager: HKWorkoutManager? = HKWorkoutManager(logger: LogManager(), liveActivityUpdater: spy)
        weak var weakManager = manager
        manager?.startRest(durationSeconds: 3600, session: session)

        manager = nil

        #expect(weakManager == nil)
    }
}

#endif

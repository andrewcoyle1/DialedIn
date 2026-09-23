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

    // MARK: - The content state

    private func set(
        id: String,
        reps: Int,
        weightKg: Double,
        isWarmup: Bool = false,
        completedAt: Date? = nil
    ) -> WorkoutSetModel {
        WorkoutSetModel(
            id: id,
            authorId: "author-1",
            index: 1,
            reps: reps,
            weightKg: weightKg,
            isWarmup: isWarmup,
            completedAt: completedAt,
            dateCreated: Date(timeIntervalSince1970: 1_772_000_000)
        )
    }

    private func exercise(id: String, name: String, index: Int, sets: [WorkoutSetModel]) -> WorkoutExerciseModel {
        WorkoutExerciseModel(
            id: id,
            authorId: "author-1",
            templateId: "template-\(id)",
            name: name,
            trackingMode: .weightReps,
            index: index,
            sets: sets
        )
    }

    /// Two exercises: the first has a set logged a minute ago and one logged just now, the second
    /// opens with a warm-up the activity must not offer as the next target.
    private func twoExerciseSession() -> WorkoutSessionModel {
        let logged = Date(timeIntervalSince1970: 1_772_000_100)
        return WorkoutSessionModel(
            id: "s1",
            authorId: "author-1",
            name: "Upper",
            dateCreated: Date(timeIntervalSince1970: 1_772_000_000),
            exercises: [
                exercise(id: "e1", name: "Bench press", index: 1, sets: [
                    set(id: "set-1", reps: 8, weightKg: 60, completedAt: logged.addingTimeInterval(-60)),
                    set(id: "set-2", reps: 6, weightKg: 65, completedAt: logged),
                    set(id: "set-3", reps: 6, weightKg: 65)
                ]),
                exercise(id: "e2", name: "Incline press", index: 2, sets: [
                    set(id: "set-4", reps: 12, weightKg: 20, isWarmup: true),
                    set(id: "set-5", reps: 10, weightKg: 40)
                ])
            ]
        )
    }

    private func contentState(restEndsAt: Date?) -> WorkoutActivityAttributes.ContentState {
        let (manager, _) = makeManager()
        return manager.makeContentState(
            params: LiveActivityManager.MakeContentStateParams(
                session: twoExerciseSession(),
                isActive: true,
                currentExerciseIndex: 0,
                restEndsAt: restEndsAt
            )
        )
    }

    /// The rest that follows a logged set is the correction window (spec §4), so that is exactly
    /// when the activity carries the set the buttons would adjust — the most recently completed
    /// one, not the first.
    @Test("Test A Rest In Progress Carries The Set Just Logged")
    func testARestInProgressCarriesTheSetJustLogged() {
        let state = contentState(restEndsAt: Date().addingTimeInterval(60))

        #expect(state.lastLoggedSetId == "set-2")
        #expect(state.lastLoggedReps == 6)
        #expect(state.lastLoggedWeightKg == 65)
    }

    /// Rebuilding the state from the rest is what clears the window when the rest ends: there is
    /// no separate bookkeeping to forget.
    @Test("Test No Rest Leaves The Logged Set Empty")
    func testNoRestLeavesTheLoggedSetEmpty() {
        let state = contentState(restEndsAt: nil)

        #expect(state.lastLoggedSetId == nil)
        #expect(state.lastLoggedReps == nil)
        #expect(state.lastLoggedWeightKg == nil)

        let passed = contentState(restEndsAt: Date().addingTimeInterval(-1))
        #expect(passed.lastLoggedSetId == nil)
    }

    /// The `.exerciseDone` phase promises what is coming next, so the state has to name it — and
    /// the target it shows is the next exercise's first *working* set, not its warm-up.
    @Test("Test The State Names The Next Exercise And Its First Working Set")
    func testTheStateNamesTheNextExerciseAndItsFirstWorkingSet() {
        let state = contentState(restEndsAt: nil)

        #expect(state.nextExerciseName == "Incline press")
        #expect(state.nextExerciseFirstTargetWeightKg == 40)
        #expect(state.nextExerciseFirstTargetReps == 10)
    }

    /// On the last exercise there is nothing after it, which is what keeps `.exerciseDone`
    /// unreachable there.
    @Test("Test The Last Exercise Has No Next Exercise")
    func testTheLastExerciseHasNoNextExercise() {
        let (manager, _) = makeManager()
        let state = manager.makeContentState(
            params: LiveActivityManager.MakeContentStateParams(
                session: twoExerciseSession(),
                isActive: true,
                currentExerciseIndex: 1,
                restEndsAt: nil
            )
        )

        #expect(state.nextExerciseName == nil)
        #expect(state.nextExerciseFirstTargetWeightKg == nil)
    }

    // MARK: - Never describing a finished exercise

    /// The state is built from the next exercise with work left when the requested one is
    /// finished, so the rest-end push cannot strand the banner on an exercise with no target.
    @Test("Test A Finished Exercise Index Advances To The Next With Work Left")
    func testAFinishedExerciseIndexAdvancesToTheNextWithWorkLeft() {
        let logged = Date()
        let session = WorkoutSessionModel(
            id: "s2",
            authorId: "author-1",
            name: "Push Day",
            dateCreated: logged,
            exercises: [
                exercise(id: "e1", name: "Bench press", index: 1, sets: [
                    set(id: "set-1", reps: 8, weightKg: 60, completedAt: logged)
                ]),
                exercise(id: "e2", name: "Incline press", index: 2, sets: [
                    set(id: "set-2", reps: 10, weightKg: 40)
                ])
            ]
        )

        #expect(LiveActivityManager.exerciseIndexWithWorkLeft(from: 0, in: session) == 1)
        #expect(LiveActivityManager.exerciseIndexWithWorkLeft(from: 1, in: session) == 1)

        let (manager, _) = makeManager()
        let state = manager.makeContentState(
            params: LiveActivityManager.MakeContentStateParams(
                session: session,
                isActive: true,
                currentExerciseIndex: 0,
                restEndsAt: nil
            )
        )
        #expect(state.currentExerciseIndex == 1)
        #expect(state.currentExerciseName == "Incline press")
        #expect(state.targetSetId == "set-2")
    }

    /// When nothing later has work left the requested index stands, and all-sets-complete takes
    /// over from there.
    @Test("Test A Finished Last Exercise Keeps Its Index")
    func testAFinishedLastExerciseKeepsItsIndex() {
        let logged = Date()
        let session = WorkoutSessionModel(
            id: "s3",
            authorId: "author-1",
            name: "Push Day",
            dateCreated: logged,
            exercises: [
                exercise(id: "e1", name: "Bench press", index: 1, sets: [
                    set(id: "set-1", reps: 8, weightKg: 60, completedAt: logged)
                ])
            ]
        )

        #expect(LiveActivityManager.exerciseIndexWithWorkLeft(from: 0, in: session) == 0)
    }

    // MARK: - Paired sets and the position

    /// After the left half of a pair the user is still on that set, so the completed count the
    /// position is built from leaves it out; once both halves are done it counts as one.
    @Test("Test A Half Done Pair Does Not Count As A Completed Set")
    func testAHalfDonePairDoesNotCountAsACompletedSet() {
        let logged = Date()
        let left = WorkoutSetModel(
            id: "s1-left", authorId: "author-1", index: 1, reps: 8, weightKg: 20,
            side: .left, isWarmup: false, completedAt: logged, dateCreated: logged
        )
        var right = WorkoutSetModel(
            id: "s1-right", authorId: "author-1", index: 1, reps: 8, weightKg: 20,
            side: .right, isWarmup: false, completedAt: nil, dateCreated: logged
        )
        let second = WorkoutSetModel(
            id: "s2", authorId: "author-1", index: 2, reps: 8, weightKg: 20,
            side: nil, isWarmup: false, completedAt: nil, dateCreated: logged
        )

        #expect(LiveActivityManager.fullyCompletedRows(in: [left, right, second]).pairedSetCount == 0)

        right.completedAt = logged
        #expect(LiveActivityManager.fullyCompletedRows(in: [left, right, second]).pairedSetCount == 1)
    }

    /// The tracker does not order the two sides, so a right row ticked first is just as half done.
    @Test("Test A Right Row Ticked Before Its Left Partner Does Not Count Either")
    func testARightRowTickedBeforeItsLeftPartnerDoesNotCountEither() {
        let logged = Date()
        var left = WorkoutSetModel(
            id: "s1-left", authorId: "author-1", index: 1, reps: 8, weightKg: 20,
            side: .left, isWarmup: false, completedAt: nil, dateCreated: logged
        )
        let right = WorkoutSetModel(
            id: "s1-right", authorId: "author-1", index: 1, reps: 8, weightKg: 20,
            side: .right, isWarmup: false, completedAt: logged, dateCreated: logged
        )

        #expect(LiveActivityManager.fullyCompletedRows(in: [left, right]).pairedSetCount == 0)

        left.completedAt = logged
        #expect(LiveActivityManager.fullyCompletedRows(in: [left, right]).pairedSetCount == 1)
    }
}

#endif

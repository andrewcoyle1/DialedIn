//
//  LiveActivityScenarioTests.swift
//  DialedInUnitTests
//
//  A whole workout driven the way a user drives it from the Lock Screen: tap what the activity
//  shows, and after every tap check what the activity would show next. The widget is a pure
//  function of the content state (`LiveActivityPhase`), so asserting the phase after each push is
//  asserting what the user sees, without SpringBoard in the loop.
//
//  The two bugs this exists for were both in this loop: a completion the app never consumed, and a
//  push that pointed at a finished exercise and left the banner with no target and no way out.
//

import Foundation
import Testing
@testable import DialedIn

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)

@MainActor
struct LiveActivityScenarioTests {

    private static let start = Date(timeIntervalSince1970: 1_772_000_000)

    // MARK: - Fixture: four exercises, two warm-ups and four working sets each

    private func set(exercise: Int, index: Int, warmup: Bool) -> WorkoutSetModel {
        WorkoutSetModel(
            id: "e\(exercise)-s\(index)",
            authorId: "author-1",
            index: index,
            reps: warmup ? 10 : 8,
            weightKg: warmup ? 40 : 60 + Double(exercise) * 5,
            rpe: nil,
            isWarmup: warmup,
            completedAt: nil,
            dateCreated: Self.start
        )
    }

    private func exercise(_ number: Int) -> WorkoutExerciseModel {
        let warmups = (1...2).map { set(exercise: number, index: $0, warmup: true) }
        let working = (3...6).map { set(exercise: number, index: $0, warmup: false) }
        return WorkoutExerciseModel(
            id: "e\(number)",
            authorId: "author-1",
            templateId: "template-\(number)",
            name: "Exercise \(number)",
            trackingMode: .weightReps,
            index: number,
            sets: warmups + working
        )
    }

    private func session() -> WorkoutSessionModel {
        WorkoutSessionModel(
            id: "scenario-session",
            authorId: "author-1",
            name: "Full Body",
            dateCreated: Self.start,
            exercises: (1...4).map(exercise)
        )
    }

    private struct Rig {
        let handler: AppLiveActivityIntentHandler
        let sessions: WorkoutSessionManager
        let hkWorkoutManager: HKWorkoutManager
        let activity: LiveActivityManager
    }

    private func makeRig() async throws -> Rig {
        SharedWorkoutStorage.clearRestEndTime()

        var settings = WorkoutSettings(authorId: "author-1")
        settings.defaultRestDurationSeconds = 90
        settings.restAfterLastWarmUp = true

        let sessions = TestManagers.workoutSessionManager()
        try sessions.updateActiveSession(session())

        let activity = LiveActivityManager(logger: LogManager())
        let hkWorkoutManager = HKWorkoutManager(logger: LogManager(), liveActivityUpdater: activity)
        let handler = AppLiveActivityIntentHandler(
            workoutSessionManager: sessions,
            hkWorkoutManager: hkWorkoutManager,
            liveActivityUpdater: activity,
            workoutSettingsManager: try await TestManagers.signedInWorkoutSettingsManager(settings),
            exerciseSettingsManager: TestManagers.exerciseSettingsManager(),
            exerciseModelManager: TestManagers.exerciseModelManager()
        )
        return Rig(handler: handler, sessions: sessions, hkWorkoutManager: hkWorkoutManager, activity: activity)
    }

    /// What the Lock Screen would show for the last state the app pushed.
    private func phase(_ rig: Rig, now: Date = Date(), isStale: Bool = false) throws -> LiveActivityPhase {
        let state = try #require(rig.activity.lastContentState, "the app has pushed nothing")
        return LiveActivityPhase(state: state, now: now, isStale: isStale)
    }

    // MARK: - The whole workout from the Lock Screen

    /// One tap on Complete for whatever the activity currently offers, then whatever the user
    /// would do next: end the rest if one started. Returns the set that was logged and the
    /// exercise the activity moved to. Records an issue if the banner is left with no way forward.
    private func tapComplete(_ rig: Rig, tapNumber: Int, isLast: Bool) async throws -> (setId: String, exerciseIndex: Int) {
        let before = try #require(rig.activity.lastContentState)
        let targetId = try #require(before.targetSetId, "no target to tap for set \(tapNumber)")

        await rig.handler.completeSet(id: targetId)

        let after = try #require(rig.activity.lastContentState)
        switch try phase(rig) {
        case .resting(let until, let next, let logged):
            #expect(logged?.setId == targetId)
            if !isLast {
                #expect(next != nil, "resting after set \(tapNumber) shows no next target")
                try expectRestOverOffersAWayForward(rig, restEndsAt: until, tapNumber: tapNumber)
            }
            rig.hkWorkoutManager.endRest()
        case .ready:
            break   // no rest after this one (a warm-up); straight on
        case .allSetsDone:
            #expect(isLast, "all sets done after only \(tapNumber)")
        case let other:
            Issue.record("after set \(tapNumber) (\(targetId)) the activity shows \(other)")
        }
        return (targetId, after.currentExerciseIndex)
    }

    /// Layer 1 of rest expiry: the system re-renders when the stale date passes, before the app
    /// does anything. That render must still offer a set to complete.
    private func expectRestOverOffersAWayForward(_ rig: Rig, restEndsAt: Date, tapNumber: Int) throws {
        let stale = try phase(rig, now: restEndsAt.addingTimeInterval(1), isStale: true)
        guard case .restOver(let next) = stale else {
            Issue.record("stale rest after set \(tapNumber) is not .restOver: \(stale)")
            return
        }
        #expect(!next.isEmpty, "rest over after set \(tapNumber) with an empty target")
    }

    /// Tap Complete on whatever the activity shows, twenty-four times, ending every rest on the
    /// way. The banner must always offer a next set until the last one, must move on to the next
    /// exercise after each last set, and must end on all-sets-done and then the summary.
    @Test("Test A Four Exercise Workout Can Be Completed Entirely From The Activity")
    func testAFourExerciseWorkoutCanBeCompletedEntirelyFromTheActivity() async throws {
        let rig = try await makeRig()
        let session = try #require(rig.sessions.activeSession)
        rig.hkWorkoutManager.startWorkout(workout: session)

        // The app pushes on the first action; seed the activity the way the tracker does on appear.
        rig.activity.updateLiveActivity(params: LiveActivityUpdateParams(
            session: session, isActive: true, currentExerciseIndex: 0, restEndsAt: nil,
            statusMessage: nil, totalVolumeKg: nil, elapsedTime: 0
        ))
        guard case .ready(_, let position) = try phase(rig) else {
            Issue.record("expected .ready at the start, got \(try phase(rig))"); return
        }
        #expect(position.index == 1)

        var completed: [String] = []
        var exerciseIndexAfterEachSet: [Int] = []
        for tap in 1...24 {
            let step = try await tapComplete(rig, tapNumber: tap, isLast: tap == 24)
            completed.append(step.setId)
            exerciseIndexAfterEachSet.append(step.exerciseIndex)
        }

        #expect(Set(completed).count == 24, "a set was completed twice")
        // Each exercise's sixth completion moves the activity on, and the index never goes back.
        #expect(exerciseIndexAfterEachSet[5] == 1, "stuck on exercise 1 after its last set")
        #expect(exerciseIndexAfterEachSet[11] == 2)
        #expect(exerciseIndexAfterEachSet[17] == 3)
        #expect(exerciseIndexAfterEachSet == exerciseIndexAfterEachSet.sorted())

        guard case .allSetsDone = try phase(rig) else {
            Issue.record("after the last set the activity shows \(try phase(rig)) instead of .allSetsDone"); return
        }

        await rig.handler.completeWorkout()

        guard case .ended(let summary) = try phase(rig) else {
            Issue.record("after Finish the activity shows \(try phase(rig)) instead of .ended"); return
        }
        #expect(summary.completedSetsCount == 24)
        #expect(summary.totalExercisesCount == 4)
    }

    /// Correcting the reps during the rest changes the logged set the banner names, and only that.
    @Test("Test A Reps Correction During The Rest Reaches The Activity")
    func testARepsCorrectionDuringTheRestReachesTheActivity() async throws {
        let rig = try await makeRig()
        rig.hkWorkoutManager.startWorkout(workout: try #require(rig.sessions.activeSession))

        // Through both warm-ups to the first working set.
        for id in ["e1-s1", "e1-s2", "e1-s3"] {
            await rig.handler.completeSet(id: id)
            if rig.hkWorkoutManager.restEndTime != nil, id != "e1-s3" {
                rig.hkWorkoutManager.endRest()
            }
        }
        guard case .resting(_, _, let logged) = try phase(rig) else {
            Issue.record("expected to be resting after the first working set, got \(try phase(rig))"); return
        }
        #expect(logged?.setId == "e1-s3")
        #expect(logged?.reps == 8)

        await rig.handler.adjustLastSetReps(id: "e1-s3", delta: -2)

        guard case .resting(_, _, let corrected) = try phase(rig) else {
            Issue.record("the correction changed the phase to \(try phase(rig))"); return
        }
        #expect(corrected?.reps == 6, "the activity still shows the uncorrected reps")

        let saved = try #require(rig.sessions.activeSession?.exercises[0].sets.first { $0.id == "e1-s3" })
        #expect(saved.reps == 6)
        #expect(saved.completedAt != nil)
        #expect(saved.weightKg == 65)
    }

    /// After the last set of an exercise the activity must not point at that exercise: there is
    /// nothing left on it to complete, and a banner with no target has no way forward.
    @Test("Test The Last Set Of An Exercise Moves The Activity To The Next Exercise")
    func testTheLastSetOfAnExerciseMovesTheActivityToTheNextExercise() async throws {
        let rig = try await makeRig()
        rig.hkWorkoutManager.startWorkout(workout: try #require(rig.sessions.activeSession))

        for index in 1...6 {
            await rig.handler.completeSet(id: "e1-s\(index)")
            if rig.hkWorkoutManager.restEndTime != nil, index < 6 {
                rig.hkWorkoutManager.endRest()
            }
        }

        let state = try #require(rig.activity.lastContentState)
        #expect(state.currentExerciseIndex == 1)
        #expect(state.currentExerciseName == "Exercise 2")
        #expect(state.targetSetId == "e2-s1")

        guard case .resting(let until, let next, _) = try phase(rig) else {
            Issue.record("expected a rest before exercise 2, got \(try phase(rig))"); return
        }
        #expect(next != nil)
        guard case .restOver(let over) = try phase(rig, now: until.addingTimeInterval(1), isStale: true) else {
            Issue.record("the stale rest is not .restOver"); return
        }
        #expect(!over.isEmpty)
        if case .exerciseDone = try phase(rig, now: until.addingTimeInterval(1), isStale: false) {
            Issue.record("the activity fell into .exerciseDone, which has no button")
        }
    }
}

#endif

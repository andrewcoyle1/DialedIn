//
//  WorkoutTrackerRestFeedbackTests.swift
//  DialedInUnitTests
//
//  Split out of WorkoutTrackerPresenterTests.swift, which exceeded the 750-line file and
//  500-line type-body limits.
//

import Testing
import Foundation
import SwiftUI
import HealthKit
@testable import DialedIn

/// What the tracker does around a rest, and where it looks for the figures it shows beside the
/// current set.
///
/// Both are settings-dependent and both defaults matter: `previousWorkoutReference` defaults to
/// `.anyWorkout`, which is the unrestricted lookup every user has today, and the two rest-timer
/// announcements default to on, so a rest ending is announced unless the user says otherwise.
@MainActor
struct WorkoutTrackerRestFeedbackTests {

    private struct Screen {
        let presenter: WorkoutTrackerPresenter
        let interactor: WorkoutTrackerInteractorDouble
        let router: WorkoutTrackerRouterDouble
    }

    private let start = Date(timeIntervalSince1970: 1_000_000)

    private func settle() async {
        for _ in 0..<10 {
            await Task.yield()
        }
    }

    private func set(
        _ index: Int,
        reps: Int? = 8,
        weightKg: Double? = 80,
        isWarmup: Bool = false,
        done: Bool = false
    ) -> WorkoutSetModel {
        WorkoutSetModel(
            id: "set-\(index)-\(isWarmup ? "w" : "x")",
            authorId: "author-1",
            index: index,
            reps: reps,
            weightKg: weightKg,
            isWarmup: isWarmup,
            completedAt: done ? start : nil,
            dateCreated: start
        )
    }

    private func exercise(id: String, index: Int, sets: [WorkoutSetModel]) -> WorkoutExerciseModel {
        WorkoutExerciseModel(
            id: id,
            authorId: "author-1",
            templateId: "template-\(id)",
            name: "Bench Press",
            trackingMode: .weightReps,
            index: index,
            // A set's id is rebuilt to carry its exercise, so two exercises never share one.
            sets: sets.map { original in
                WorkoutSetModel(
                    id: "\(id)-\(original.id)",
                    authorId: original.authorId,
                    index: original.index,
                    reps: original.reps,
                    weightKg: original.weightKg,
                    isWarmup: original.isWarmup,
                    completedAt: original.completedAt,
                    dateCreated: original.dateCreated
                )
            }
        )
    }

    private func session(
        exercises: [WorkoutExerciseModel],
        templateId: String? = nil,
        programId: String? = nil
    ) -> WorkoutSessionModel {
        WorkoutSessionModel(
            id: "session-1",
            authorId: "author-1",
            name: "Push Day",
            workoutTemplateId: templateId,
            trainingProgramId: programId,
            dateCreated: start,
            exercises: exercises
        )
    }

    /// A finished session the previous-values lookup can find.
    private func completed(
        id: String,
        templateId: String,
        programId: String?,
        endedAt: Date
    ) -> WorkoutSessionModel {
        WorkoutSessionModel(
            id: id,
            authorId: "author-1",
            name: "Push Day",
            workoutTemplateId: templateId,
            trainingProgramId: programId,
            dateCreated: start,
            endedAt: endedAt,
            exercises: []
        )
    }

    /// Builds the screen the way the app does: the presenter reads the session the interactor
    /// already holds.
    private func makeScreen(
        exercises: [WorkoutExerciseModel],
        settings: (inout WorkoutSettings) -> Void = { _ in },
        templateId: String? = nil,
        programId: String? = nil
    ) throws -> Screen {
        let interactor = WorkoutTrackerInteractorDouble()
        interactor.activeSession = session(exercises: exercises, templateId: templateId, programId: programId)
        settings(&interactor.workoutSettings)
        let router = WorkoutTrackerRouterDouble()
        return Screen(
            presenter: try WorkoutTrackerPresenter(interactor: interactor, router: router),
            interactor: interactor,
            router: router
        )
    }

    // MARK: - Previous values

    /// A workout logged freehand has no template to compare against, so there is no previous
    /// session to show.
    @Test("Test A Workout Without A Template Has No Previous Session")
    func testAWorkoutWithoutATemplateHasNoPreviousSession() async throws {
        let screen = try makeScreen(exercises: [exercise(id: "e1", index: 1, sets: [set(1)])])
        screen.interactor.lastCompletedSession = session(exercises: [])

        screen.presenter.loadPreviousWorkoutSession()
        await settle()

        #expect(screen.presenter.previousWorkoutSession == nil)
    }

    @Test("Test A Workout From A Template Loads What Was Done Last Time")
    func testAWorkoutFromATemplateLoadsWhatWasDoneLastTime() async throws {
        let screen = try makeScreen(
            exercises: [exercise(id: "e1", index: 1, sets: [set(1)])],
            templateId: "template-1"
        )
        screen.interactor.lastCompletedSession = session(exercises: [])

        screen.presenter.loadPreviousWorkoutSession()
        await settle()

        #expect(screen.presenter.previousWorkoutSession != nil)
    }

    /// The default. Nothing is filtered, so the previous column shows the last time this workout
    /// was done however it was reached — which is what every user has today.
    @Test("Test Any-Workout Reference Searches Every Session")
    func testAnyWorkoutReferenceSearchesEverySession() async throws {
        let screen = try makeScreen(
            exercises: [exercise(id: "e1", index: 1, sets: [set(1)])],
            templateId: "template-1",
            programId: "program-1"
        )
        #expect(screen.interactor.workoutSettings.previousWorkoutReference == .anyWorkout)
        screen.interactor.completedSessions = [
            completed(id: "old-in-program", templateId: "template-1", programId: "program-1", endedAt: start),
            completed(id: "recent-freehand", templateId: "template-1", programId: nil, endedAt: start.addingTimeInterval(60))
        ]

        screen.presenter.loadPreviousWorkoutSession()
        await settle()

        #expect(screen.interactor.lastCompletedSessionLookups == [nil])
        #expect(screen.presenter.previousWorkoutSession?.id == "recent-freehand")
    }

    /// Turned on, the same lookup skips the more recent session logged outside the program and
    /// reaches back to the last one done within it.
    @Test("Test In-Program Reference Skips Sessions From Outside The Program")
    func testInProgramReferenceSkipsSessionsFromOutsideTheProgram() async throws {
        let screen = try makeScreen(
            exercises: [exercise(id: "e1", index: 1, sets: [set(1)])],
            settings: { $0.previousWorkoutReference = .workoutsInProgram },
            templateId: "template-1",
            programId: "program-1"
        )
        screen.interactor.completedSessions = [
            completed(id: "old-in-program", templateId: "template-1", programId: "program-1", endedAt: start),
            completed(id: "recent-freehand", templateId: "template-1", programId: nil, endedAt: start.addingTimeInterval(60)),
            completed(id: "other-program", templateId: "template-1", programId: "program-2", endedAt: start.addingTimeInterval(120))
        ]

        screen.presenter.loadPreviousWorkoutSession()
        await settle()

        #expect(screen.interactor.lastCompletedSessionLookups == ["program-1"])
        #expect(screen.presenter.previousWorkoutSession?.id == "old-in-program")
    }

    /// A one-off workout is in no program, so there is no program for it to be "within". Filtering
    /// on nothing would blank the previous column instead of narrowing it.
    @Test("Test In-Program Reference Does Not Filter A Workout Outside Any Program")
    func testInProgramReferenceDoesNotFilterAWorkoutOutsideAnyProgram() async throws {
        let screen = try makeScreen(
            exercises: [exercise(id: "e1", index: 1, sets: [set(1)])],
            settings: { $0.previousWorkoutReference = .workoutsInProgram },
            templateId: "template-1"
        )
        screen.interactor.completedSessions = [
            completed(id: "in-program", templateId: "template-1", programId: "program-1", endedAt: start)
        ]

        screen.presenter.loadPreviousWorkoutSession()
        await settle()

        #expect(screen.interactor.lastCompletedSessionLookups == [nil])
        #expect(screen.presenter.previousWorkoutSession?.id == "in-program")
    }

    // MARK: - Announcing the end of a rest

    /// Both on by default, so a rest ending is announced to every existing user in both ways.
    @Test("Test A Finished Rest Is Announced By Sound And Vibration")
    func testAFinishedRestIsAnnouncedBySoundAndVibration() throws {
        let screen = try makeScreen(exercises: [exercise(id: "e1", index: 1, sets: [set(1)])])
        #expect(screen.interactor.workoutSettings.restTimerPlaySound)
        #expect(screen.interactor.workoutSettings.restTimerVibrate)

        screen.presenter.announceRestCompletion()

        #expect(screen.interactor.playedSounds == [.restComplete])
        #expect(screen.interactor.playedHaptics.count == 1)
    }

    /// The two are separate settings because a gym is a place where one is wanted without the
    /// other. Turning the sound off must leave the vibration alone.
    @Test("Test A Finished Rest Only Vibrates When The Sound Is Off")
    func testAFinishedRestOnlyVibratesWhenTheSoundIsOff() throws {
        let screen = try makeScreen(
            exercises: [exercise(id: "e1", index: 1, sets: [set(1)])],
            settings: { $0.restTimerPlaySound = false }
        )

        screen.presenter.announceRestCompletion()

        #expect(screen.interactor.playedSounds.isEmpty)
        #expect(screen.interactor.playedHaptics.count == 1)
    }

    @Test("Test A Finished Rest Only Sounds When The Vibration Is Off")
    func testAFinishedRestOnlySoundsWhenTheVibrationIsOff() throws {
        let screen = try makeScreen(
            exercises: [exercise(id: "e1", index: 1, sets: [set(1)])],
            settings: { $0.restTimerVibrate = false }
        )

        screen.presenter.announceRestCompletion()

        #expect(screen.interactor.playedSounds == [.restComplete])
        #expect(screen.interactor.playedHaptics.isEmpty)
    }

    /// With both off the rest ends in silence, which is the whole point of turning them off.
    @Test("Test A Finished Rest Says Nothing When Both Are Off")
    func testAFinishedRestSaysNothingWhenBothAreOff() throws {
        let screen = try makeScreen(
            exercises: [exercise(id: "e1", index: 1, sets: [set(1)])],
            settings: {
                $0.restTimerPlaySound = false
                $0.restTimerVibrate = false
            }
        )

        screen.presenter.announceRestCompletion()

        #expect(screen.interactor.playedSounds.isEmpty)
        #expect(screen.interactor.playedHaptics.isEmpty)
    }

    /// The sound has to be loaded before it is wanted, so starting a rest loads it — but only when
    /// there is a sound to play at the end of it.
    @Test("Test Starting A Rest Loads The Sound Only When It Will Be Played")
    func testStartingARestLoadsTheSoundOnlyWhenItWillBePlayed() throws {
        let screen = try makeScreen(exercises: [exercise(id: "e1", index: 1, sets: [set(1)])])

        screen.presenter.startRestTimer(durationSeconds: 60)
        #expect(screen.interactor.preparedSounds == [.restComplete])

        let silent = try makeScreen(
            exercises: [exercise(id: "e1", index: 1, sets: [set(1)])],
            settings: { $0.restTimerPlaySound = false }
        )

        silent.presenter.startRestTimer(durationSeconds: 60)
        #expect(silent.interactor.preparedSounds.isEmpty)
    }
}

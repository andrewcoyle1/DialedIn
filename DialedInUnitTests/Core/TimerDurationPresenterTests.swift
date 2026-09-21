//
//  TimerDurationPresenterTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 21/09/2026.
//

import Testing
import Foundation
import SwiftUI
@testable import DialedIn

/// Saving happens in a detached `Task`, so a test has to let the loop turn before asserting.
private func settleDurations() async {
    for _ in 0..<10 {
        await Task.yield()
    }
}

/// How long a rest is, per kind of exercise and per individual exercise.
@MainActor
struct TimerDurationPresenterTests {

    private final class Interactor: SpyGlobalInteractor, TimerDurationInteractor {
        var workoutSettings = WorkoutSettings(authorId: "user-1")
        var allExercises: [ExerciseModel] = []
        var allExerciseSettings: [ExerciseSettingsModel] = []
        private(set) var savedSettings: [WorkoutSettings] = []
        private(set) var overridesWritten: [(String, Int?)] = []

        func saveWorkoutSettings(_ workoutSettings: WorkoutSettings) async throws {
            savedSettings.append(workoutSettings)
            self.workoutSettings = workoutSettings
        }

        func exerciseRestOverride(for exerciseId: String) -> Int? {
            allExerciseSettings.first(where: { $0.id == exerciseId })?.restDurationOverride
        }

        func setExerciseRestOverride(_ seconds: Int?, for exerciseId: String) async throws {
            overridesWritten.append((exerciseId, seconds))
        }
    }

    private final class Router: TimerDurationRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    private struct Screen {
        let presenter: TimerDurationPresenter
        let interactor: Interactor
    }

    private func exercise(_ id: String, name: String) -> ExerciseModel {
        ExerciseModel(
            id: id,
            authorId: "user-1",
            name: name,
            trackableMetrics: [.weight, .reps],
            type: .compoundUpper,
            laterality: .bilateral,
            muscleGroups: [:],
            isBodyweight: false,
            rangeOfMotion: 1,
            stability: 1,
            bodyWeightContribution: 0,
            alternateNames: []
        )
    }

    private func setting(_ id: String, override: Int?) -> ExerciseSettingsModel {
        var setting = ExerciseSettingsModel(id: id, authorId: "user-1")
        setting.restDurationOverride = override
        return setting
    }

    private func makeScreen(
        settings: WorkoutSettings = WorkoutSettings(authorId: "user-1"),
        exercises: [ExerciseModel] = [],
        exerciseSettings: [ExerciseSettingsModel] = []
    ) -> Screen {
        let interactor = Interactor()
        interactor.workoutSettings = settings
        interactor.allExercises = exercises
        interactor.allExerciseSettings = exerciseSettings
        return Screen(
            presenter: TimerDurationPresenter(interactor: interactor, router: Router()),
            interactor: interactor
        )
    }

    // MARK: - Durations per exercise type

    /// A user who has never touched these gets the defaults the app ships with, not zero — a zero
    /// rest would skip the timer entirely.
    @Test("Test Untouched Exercise Types Use Their Default Rest")
    func testUntouchedExerciseTypesUseTheirDefaultRest() {
        let screen = makeScreen()

        #expect(screen.presenter.duration(for: .compoundUpper) == 180)
        #expect(screen.presenter.duration(for: .isolationLower) == 90)
        #expect(screen.presenter.duration(for: .core) == 60)
    }

    @Test("Test A Stored Duration Overrides The Default")
    func testAStoredDurationOverridesTheDefault() {
        var settings = WorkoutSettings(authorId: "user-1")
        settings.restDurationsByExerciseType = ["compoundUpper": 240]
        let screen = makeScreen(settings: settings)

        #expect(screen.presenter.duration(for: .compoundUpper) == 240)
        #expect(screen.presenter.duration(for: .compoundLower) == 180)
    }

    /// Seconds are shown as minutes and seconds, with the seconds padded — 90 is 1:30, not 1:3.
    @Test("Test A Duration Reads As Minutes And Seconds")
    func testADurationReadsAsMinutesAndSeconds() {
        let screen = makeScreen()

        #expect(screen.presenter.formattedDuration(seconds: 90) == "1:30")
        #expect(screen.presenter.formattedDuration(seconds: 65) == "1:05")
        #expect(screen.presenter.formattedDuration(seconds: 45) == "0:45")
        #expect(screen.presenter.formattedDuration(seconds: 180) == "3:00")
    }

    /// The editor opens on the duration already set, split into the two wheels, so a user changing
    /// the seconds does not lose the minutes.
    @Test("Test Editing A Duration Opens On What Is Already Set")
    func testEditingADurationOpensOnWhatIsAlreadySet() {
        var settings = WorkoutSettings(authorId: "user-1")
        settings.restDurationsByExerciseType = ["core": 95]
        let screen = makeScreen(settings: settings)

        screen.presenter.onEditPressed(type: .core)

        #expect(screen.presenter.editMinutes == 1)
        #expect(screen.presenter.editSeconds == 35)
        #expect(screen.presenter.editingType == .core)
    }

    @Test("Test A Saved Duration Is Both Wheels Together")
    func testASavedDurationIsBothWheelsTogether() async {
        let screen = makeScreen()
        screen.presenter.onEditPressed(type: .compoundLower)
        screen.presenter.editMinutes = 2
        screen.presenter.editSeconds = 30

        screen.presenter.saveEdit()
        await settleDurations()

        #expect(screen.interactor.savedSettings.last?.restDurationsByExerciseType["compoundLower"] == 150)
        #expect(screen.presenter.editingType == nil)
    }

    /// Setting one type's rest must not clear the others, which sit in the same dictionary.
    @Test("Test Saving One Duration Leaves The Other Types Alone")
    func testSavingOneDurationLeavesTheOtherTypesAlone() async {
        var settings = WorkoutSettings(authorId: "user-1")
        settings.restDurationsByExerciseType = ["core": 45]
        let screen = makeScreen(settings: settings)
        screen.presenter.onEditPressed(type: .compoundUpper)
        screen.presenter.editMinutes = 3
        screen.presenter.editSeconds = 0

        screen.presenter.saveEdit()
        await settleDurations()

        let saved = screen.interactor.savedSettings.last?.restDurationsByExerciseType
        #expect(saved?["compoundUpper"] == 180)
        #expect(saved?["core"] == 45)
    }

    /// With no row being edited there is nothing to save to, and writing anyway would land on
    /// whichever row was edited last.
    @Test("Test Saving With No Row Being Edited Writes Nothing")
    func testSavingWithNoRowBeingEditedWritesNothing() async {
        let screen = makeScreen()

        screen.presenter.saveEdit()
        await settleDurations()

        #expect(screen.interactor.savedSettings.isEmpty)
    }

    /// Resetting clears the overrides so every type falls back to the shipped default, rather than
    /// setting them all to zero.
    @Test("Test Resetting Clears Every Stored Duration")
    func testResettingClearsEveryStoredDuration() async {
        var settings = WorkoutSettings(authorId: "user-1")
        settings.restDurationsByExerciseType = ["core": 45, "compoundUpper": 240]
        let screen = makeScreen(settings: settings)

        screen.presenter.resetDefaults()
        await settleDurations()

        #expect(screen.interactor.savedSettings.last?.restDurationsByExerciseType.isEmpty == true)
        #expect(screen.presenter.duration(for: .compoundUpper) == 180)
    }

    // MARK: - Per-exercise overrides

    /// Only exercises with an override of their own are listed, and each is shown by name — a
    /// setting whose exercise has since gone would otherwise be an untappable blank row.
    @Test("Test Only Exercises With An Override Are Listed")
    func testOnlyExercisesWithAnOverrideAreListed() {
        let screen = makeScreen(
            exercises: [exercise("a", name: "Squat"), exercise("b", name: "Bench Press")],
            exerciseSettings: [
                setting("a", override: 200),
                setting("b", override: nil),
                setting("gone", override: 120)
            ]
        )

        #expect(screen.presenter.exerciseOverrides.map(\.id) == ["a"])
        #expect(screen.presenter.exerciseOverrides.first?.name == "Squat")
        #expect(screen.presenter.exerciseOverrides.first?.seconds == 200)
    }

    @Test("Test Overrides Are Listed In Name Order")
    func testOverridesAreListedInNameOrder() {
        let screen = makeScreen(
            exercises: [exercise("a", name: "Squat"), exercise("b", name: "Bench Press")],
            exerciseSettings: [setting("a", override: 200), setting("b", override: 100)]
        )

        #expect(screen.presenter.exerciseOverrides.map(\.name) == ["Bench Press", "Squat"])
    }

    /// The picker offers what is left, so an exercise cannot be given a second override that would
    /// contradict the first.
    @Test("Test The Picker Leaves Out Exercises Already Overridden")
    func testThePickerLeavesOutExercisesAlreadyOverridden() {
        let screen = makeScreen(
            exercises: [exercise("a", name: "Squat"), exercise("b", name: "Bench Press")],
            exerciseSettings: [setting("a", override: 200)]
        )

        #expect(screen.presenter.exercisesWithoutOverride.map(\.id) == ["b"])
    }

    /// A newly picked exercise opens on the global default rather than on nothing, so the wheels
    /// start somewhere sensible.
    @Test("Test A Newly Picked Exercise Opens On The Default Rest")
    func testANewlyPickedExerciseOpensOnTheDefaultRest() {
        var settings = WorkoutSettings(authorId: "user-1")
        settings.defaultRestDurationSeconds = 135
        let screen = makeScreen(settings: settings, exercises: [exercise("a", name: "Squat")])

        screen.presenter.onExercisePicked(exercise("a", name: "Squat"))

        #expect(screen.presenter.editMinutes == 2)
        #expect(screen.presenter.editSeconds == 15)
        #expect(screen.presenter.editingExerciseName == "Squat")
        #expect(screen.presenter.isEditingExercise)
        #expect(!screen.presenter.isAddingExerciseTimer)
    }

    @Test("Test An Exercise Override Is Saved Against That Exercise")
    func testAnExerciseOverrideIsSavedAgainstThatExercise() async {
        let screen = makeScreen(exercises: [exercise("a", name: "Squat")])
        screen.presenter.onExercisePicked(exercise("a", name: "Squat"))
        screen.presenter.editMinutes = 4
        screen.presenter.editSeconds = 0

        screen.presenter.saveExerciseEdit()
        await settleDurations()

        #expect(screen.interactor.overridesWritten.first?.0 == "a")
        #expect(screen.interactor.overridesWritten.first?.1 == 240)
    }

    /// Removing an override sends nothing rather than zero, so the exercise falls back to its
    /// type's rest instead of resting for no time at all.
    @Test("Test Removing An Override Sends Nothing Rather Than Zero")
    func testRemovingAnOverrideSendsNothingRatherThanZero() async {
        let screen = makeScreen(
            exercises: [exercise("a", name: "Squat")],
            exerciseSettings: [setting("a", override: 200)]
        )
        let override = TimerDurationPresenter.ExerciseOverride(id: "a", name: "Squat", seconds: 200)

        screen.presenter.removeExerciseOverride(override)
        await settleDurations()

        #expect(screen.interactor.overridesWritten.first?.0 == "a")
        #expect(screen.interactor.overridesWritten.first?.1 == nil)
    }

    @Test("Test Saving With No Exercise Being Edited Writes Nothing")
    func testSavingWithNoExerciseBeingEditedWritesNothing() async {
        let screen = makeScreen()

        screen.presenter.saveExerciseEdit()
        await settleDurations()

        #expect(screen.interactor.overridesWritten.isEmpty)
    }
}

//
//  WorkoutTrackingRowPresenterTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 21/09/2026.
//

import Testing
import Foundation
import SwiftUI
@testable import DialedIn

/// One row of a live workout: the set being lifted right now.
///
/// This is the screen the user actually touches between sets, and it owns three things that go
/// wrong quietly — whether a set is allowed to be marked done, how long the rest timer that fires
/// afterwards runs for, and which of the several rest durations the picker is showing. A row is
/// rebuilt per set, so anything it holds in memory is per-row state, and anything it reads has to
/// come back from the interactor the same way twice.
@MainActor
struct SetTrackerRowPresenterTests {

    // MARK: - Doubles

    private final class Interactor: SpyGlobalInteractor, SetTrackerRowInteractor {
        var workoutSettings: WorkoutSettings = WorkoutSettings(authorId: "user-1")
        var allExercises: [ExerciseModel] = []
        var preferences: [String: ExerciseUnitPreference] = [:]

        func getPreference(templateId: String) -> ExerciseUnitPreference {
            preferences[templateId] ?? ExerciseUnitPreference(exerciseModelId: templateId)
        }
    }

    /// `dismissModal()` is a `GlobalRouter` extension and not restated by `SetTrackerRowRouter`,
    /// so it dispatches statically and never reaches this double. The rest-picker tests drive the
    /// captured Save action and assert the duration it stored instead.
    private final class Router: SetTrackerRowRouter {
        let router: AnyRouter = TestRouting.anyRouter
        private(set) var shown: [String] = []
        private(set) var restPrimaryAction: (() -> Void)?
        private(set) var restMinutes: Binding<Int>?
        private(set) var restSeconds: Binding<Int>?

        func showWarmupSetInfoModal(primaryButtonAction: @escaping () -> Void) {
            shown.append("warmupInfo")
        }

        func showRestModal(
            primaryButtonAction: @escaping () -> Void,
            secondaryButtonAction: @escaping () -> Void,
            minutesSelection: Binding<Int>,
            secondsSelection: Binding<Int>
        ) {
            shown.append("rest")
            restPrimaryAction = primaryButtonAction
            restMinutes = minutesSelection
            restSeconds = secondsSelection
        }
    }

    /// Holds a value the presenter edits through a `Binding`, so its methods can be driven without
    /// a view and the result read back. Main-actor isolated so it is `Sendable`, which `Binding`'s
    /// `@Sendable` accessors require.
    @MainActor
    private final class Box<Value> {
        var value: Value

        init(_ value: Value) {
            self.value = value
        }

        var binding: Binding<Value> {
            Binding(
                get: { MainActor.assumeIsolated { self.value } },
                set: { newValue in MainActor.assumeIsolated { self.value = newValue } }
            )
        }
    }

    private struct Screen {
        let presenter: SetTrackerRowPresenter
        let interactor: Interactor
        let router: Router
    }

    private func makeScreen() -> Screen {
        let interactor = Interactor()
        let router = Router()
        return Screen(
            presenter: SetTrackerRowPresenter(interactor: interactor, router: router),
            interactor: interactor,
            router: router
        )
    }

    private func set(
        id: String = "set-1",
        index: Int = 1,
        reps: Int? = 10,
        weightKg: Double? = 100,
        durationSec: Int? = nil,
        distanceMeters: Double? = nil,
        isWarmup: Bool = false,
        completedAt: Date? = nil
    ) -> WorkoutSetModel {
        WorkoutSetModel(
            id: id,
            authorId: "user-1",
            index: index,
            reps: reps,
            weightKg: weightKg,
            durationSec: durationSec,
            distanceMeters: distanceMeters,
            isWarmup: isWarmup,
            completedAt: completedAt,
            dateCreated: Date()
        )
    }

    private func exercise(
        templateId: String = "template-1",
        mode: TrackingMode = .weightReps,
        sets: [WorkoutSetModel] = []
    ) -> WorkoutExerciseModel {
        WorkoutExerciseModel(
            id: "exercise-1",
            authorId: "user-1",
            templateId: templateId,
            name: "Bench Press",
            trackingMode: mode,
            index: 1,
            sets: sets
        )
    }

    private func exerciseModel(id: String, type: ExerciseType) -> ExerciseModel {
        ExerciseModel(
            id: id,
            authorId: "user-1",
            name: "Bench Press",
            trackableMetrics: [.weight, .reps],
            type: type,
            laterality: .bilateral,
            muscleGroups: [:],
            isBodyweight: false,
            rangeOfMotion: 1,
            stability: 1,
            bodyWeightContribution: 0,
            alternateNames: []
        )
    }

    // MARK: - Marking a set done

    @Test("Test Completing A Set Stamps The Time")
    func testCompletingASetStampsTheTime() {
        let screen = makeScreen()
        let box = Box(set())

        screen.presenter.onSetComplete(exercise(), box.binding)

        #expect(box.value.completedAt != nil)
    }

    /// The tick is a toggle — tapping a set that is already done undoes it, which is how a set
    /// logged by mistake is taken back.
    @Test("Test Tapping A Completed Set Undoes It")
    func testTappingACompletedSetUndoesIt() {
        let screen = makeScreen()
        let box = Box(set(completedAt: Date()))

        screen.presenter.onSetComplete(exercise(), box.binding)

        #expect(box.value.completedAt == nil)
    }

    /// A set with no reps entered has not been lifted, so it must not be stamped as done however
    /// hard the tick is pressed — a completed-but-empty set becomes a zero in the training history.
    @Test("Test A Set With No Reps Is Not Marked Done")
    func testASetWithNoRepsIsNotMarkedDone() {
        let screen = makeScreen()
        let box = Box(set(reps: nil))

        screen.presenter.onSetComplete(exercise(), box.binding)

        #expect(box.value.completedAt == nil)
    }

    /// A negative weight is a typo, not a lift, so it is refused even though reps are present.
    @Test("Test A Negative Weight Is Refused")
    func testANegativeWeightIsRefused() {
        let screen = makeScreen()
        let box = Box(set(weightKg: -20))

        screen.presenter.onSetComplete(exercise(), box.binding)

        #expect(box.value.completedAt == nil)
    }

    /// A run needs both halves before it counts.
    @Test("Test A Distance Set Is Refused Without A Time")
    func testADistanceSetIsRefusedWithoutATime() {
        let screen = makeScreen()
        let box = Box(set(reps: nil, weightKg: nil, distanceMeters: 5000))

        screen.presenter.onSetComplete(exercise(mode: .distanceTime), box.binding)

        #expect(box.value.completedAt == nil)
    }

    // MARK: - The rest that follows

    @Test("Test Completing A Set Starts The Rest Timer")
    func testCompletingASetStartsTheRestTimer() {
        let screen = makeScreen()
        var started: [Int] = []
        screen.presenter.onStartRest = { started.append($0) }
        let box = Box(set())

        screen.presenter.onSetComplete(exercise(), box.binding)

        #expect(started == [90])
    }

    /// Someone who trains without a timer gets their set logged and nothing else — a rest screen
    /// appearing uninvited is the whole reason the setting exists.
    @Test("Test No Rest Starts When Rest Timers Are Off")
    func testNoRestStartsWhenRestTimersAreOff() {
        let screen = makeScreen()
        screen.interactor.workoutSettings.useRestTimers = false
        var started: [Int] = []
        screen.presenter.onStartRest = { started.append($0) }
        let box = Box(set())

        screen.presenter.onSetComplete(exercise(), box.binding)

        #expect(box.value.completedAt != nil)
        #expect(started.isEmpty)
    }

    /// Undoing a set must not start a rest — the user is correcting a mistake, not finishing work.
    @Test("Test Undoing A Set Starts No Rest")
    func testUndoingASetStartsNoRest() {
        let screen = makeScreen()
        var started: [Int] = []
        screen.presenter.onStartRest = { started.append($0) }
        let box = Box(set(completedAt: Date()))

        screen.presenter.onSetComplete(exercise(), box.binding)

        #expect(started.isEmpty)
    }

    /// Heavy compound work is rested longer than accessory work, which is what the per-type
    /// override is for.
    @Test("Test The Exercise Type Override Sets The Rest Length")
    func testTheExerciseTypeOverrideSetsTheRestLength() {
        let screen = makeScreen()
        screen.interactor.allExercises = [exerciseModel(id: "template-1", type: .compoundLower)]
        screen.interactor.workoutSettings.restDurationsByExerciseType = [ExerciseType.compoundLower.rawValue: 240]
        var started: [Int] = []
        screen.presenter.onStartRest = { started.append($0) }
        let box = Box(set())

        screen.presenter.onSetComplete(exercise(), box.binding)

        #expect(started == [240])
    }

    /// A rest set by hand on this set beats the type override, which beats the global default.
    @Test("Test A Custom Rest Beats The Type Override")
    func testACustomRestBeatsTheTypeOverride() {
        let screen = makeScreen()
        screen.interactor.allExercises = [exerciseModel(id: "template-1", type: .compoundLower)]
        screen.interactor.workoutSettings.restDurationsByExerciseType = [ExerciseType.compoundLower.rawValue: 240]
        screen.presenter.updateRestBefore(setId: "set-1", seconds: 45)
        var started: [Int] = []
        screen.presenter.onStartRest = { started.append($0) }
        let box = Box(set())

        screen.presenter.onSetComplete(exercise(), box.binding)

        #expect(started == [45])
    }

    /// An override for a different kind of lift is not this lift's rest.
    @Test("Test An Unrelated Type Override Does Not Apply")
    func testAnUnrelatedTypeOverrideDoesNotApply() {
        let screen = makeScreen()
        screen.interactor.allExercises = [exerciseModel(id: "template-1", type: .core)]
        screen.interactor.workoutSettings.restDurationsByExerciseType = [ExerciseType.compoundLower.rawValue: 240]
        var started: [Int] = []
        screen.presenter.onStartRest = { started.append($0) }
        let box = Box(set())

        screen.presenter.onSetComplete(exercise(), box.binding)

        #expect(started == [90])
    }

    // MARK: - The rest picker

    /// The one that used to be wrong. Swiping a row opens the picker on the rest that would
    /// actually run, so someone with a four-minute override for squats is not shown ninety
    /// seconds and does not quietly cut their rest in half by pressing Save.
    @Test("Test The Picker Opens On The Rest That Would Actually Run")
    func testThePickerOpensOnTheRestThatWouldActuallyRun() {
        let screen = makeScreen()
        screen.interactor.allExercises = [exerciseModel(id: "template-1", type: .compoundLower)]
        screen.interactor.workoutSettings.restDurationsByExerciseType = [ExerciseType.compoundLower.rawValue: 240]

        screen.presenter.onRestPickerRequested(exercise: exercise(), setId: "set-1")

        #expect(screen.presenter.restPickerMinutesSelection == 4)
        #expect(screen.presenter.restPickerSecondsSelection == 0)
    }

    @Test("Test The Picker Opens On A Rest Already Set By Hand")
    func testThePickerOpensOnARestAlreadySetByHand() {
        let screen = makeScreen()
        screen.presenter.updateRestBefore(setId: "set-1", seconds: 135)

        screen.presenter.onRestPickerRequested(exercise: exercise(), setId: "set-1")

        #expect(screen.presenter.restPickerMinutesSelection == 2)
        #expect(screen.presenter.restPickerSecondsSelection == 15)
        #expect(screen.router.shown == ["rest"])
    }

    /// Saving the wheels stores a rest for this set alone, and the next set completed uses it.
    @Test("Test Saving The Picker Stores The Chosen Rest")
    func testSavingThePickerStoresTheChosenRest() {
        let screen = makeScreen()
        screen.presenter.onRestPickerRequested(exercise: exercise(), setId: "set-1")
        screen.router.restMinutes?.wrappedValue = 2
        screen.router.restSeconds?.wrappedValue = 15
        screen.router.restPrimaryAction?()

        var started: [Int] = []
        screen.presenter.onStartRest = { started.append($0) }
        let box = Box(set())
        screen.presenter.onSetComplete(exercise(), box.binding)

        #expect(screen.presenter.restBeforeSetIdToSec["set-1"] == 135)
        #expect(started == [135])
    }

    /// Winding both wheels to zero means "no custom rest", so the set falls back to the settings
    /// rather than resting for no time at all.
    @Test("Test Saving Zero Clears The Custom Rest")
    func testSavingZeroClearsTheCustomRest() {
        let screen = makeScreen()
        screen.presenter.updateRestBefore(setId: "set-1", seconds: 45)
        screen.presenter.onRestPickerRequested(exercise: exercise(), setId: "set-1")
        screen.router.restMinutes?.wrappedValue = 0
        screen.router.restSeconds?.wrappedValue = 0
        screen.router.restPrimaryAction?()

        #expect(screen.presenter.restBeforeSetIdToSec["set-1"] == nil)
    }

    @Test("Test The Warmup Explanation Opens")
    func testTheWarmupExplanationOpens() {
        let screen = makeScreen()

        screen.presenter.onWarmupSetHelpPressed()

        #expect(screen.router.shown == ["warmupInfo"])
    }

    // MARK: - Deleting

    @Test("Test Deleting A Set Removes Only That One")
    func testDeletingASetRemovesOnlyThatOne() {
        let screen = makeScreen()
        let box = Box(exercise(sets: [
            set(id: "s1", index: 1), set(id: "s2", index: 2), set(id: "s3", index: 3)
        ]))

        screen.presenter.deleteSet(setId: "s2", exercise: box.binding)

        #expect(box.value.sets.map(\.id) == ["s1", "s3"])
    }

    // MARK: - When the tick is available

    /// Bodyweight work is logged at no weight, so a missing weight is allowed where missing reps
    /// are not.
    @Test("Test The Tick Needs Reps But Not A Weight")
    func testTheTickNeedsRepsButNotAWeight() {
        let screen = makeScreen()

        #expect(screen.presenter.canComplete(trackingMode: .weightReps, set: set(weightKg: nil)))
        #expect(!screen.presenter.canComplete(trackingMode: .weightReps, set: set(reps: 0)))
        #expect(!screen.presenter.canComplete(trackingMode: .weightReps, set: set(reps: nil)))
    }

    @Test("Test Each Tracking Mode Asks For Its Own Figures")
    func testEachTrackingModeAsksForItsOwnFigures() {
        let screen = makeScreen()
        let timed = set(reps: nil, weightKg: nil, durationSec: 30)
        let run = set(reps: nil, weightKg: nil, durationSec: 1500, distanceMeters: 5000)

        #expect(screen.presenter.canComplete(trackingMode: .repsOnly, set: set(weightKg: nil)))
        #expect(screen.presenter.canComplete(trackingMode: .timeOnly, set: timed))
        #expect(!screen.presenter.canComplete(trackingMode: .timeOnly, set: set()))
        #expect(screen.presenter.canComplete(trackingMode: .distanceTime, set: run))
        #expect(!screen.presenter.canComplete(trackingMode: .distanceTime, set: timed))
    }

    /// A completed set stays green even if its figures would no longer pass, so editing a logged
    /// set does not make it look undone.
    @Test("Test The Tick Colour Follows The Sets State")
    func testTheTickColourFollowsTheSetsState() {
        let screen = makeScreen()

        #expect(screen.presenter.buttonColor(set: set(completedAt: Date()), canComplete: false) == .green)
        #expect(screen.presenter.buttonColor(set: set(), canComplete: true) == .secondary)
        #expect(screen.presenter.buttonColor(set: set(), canComplete: false) != .green)
    }

    // MARK: - Units

    /// A row redraws on every keystroke in the weight field, so the preference is read once and
    /// cached rather than fetched per redraw.
    @Test("Test A Unit Preference Is Read Once And Cached")
    func testAUnitPreferenceIsReadOnceAndCached() {
        let screen = makeScreen()
        screen.interactor.preferences["template-1"] = ExerciseUnitPreference(
            exerciseModelId: "template-1",
            weightUnit: .pounds
        )
        let model = exercise()

        let first = screen.presenter.getUnitPreference(for: model)
        screen.interactor.preferences["template-1"] = ExerciseUnitPreference(
            exerciseModelId: "template-1",
            weightUnit: .kilograms
        )
        let second = screen.presenter.getUnitPreference(for: model)

        #expect(first.weightUnit == .pounds)
        #expect(second.weightUnit == .pounds)
    }

    // MARK: - Analytics

    @Test("Test Completing A Set Is Recorded")
    func testCompletingASetIsRecorded() {
        let screen = makeScreen()
        let box = Box(set())

        screen.presenter.onSetComplete(exercise(), box.binding)

        #expect(screen.interactor.trackedEventNames.contains("SetTrackerRow_SetCompleted"))
    }

    @Test("Test The Row Records Appearing And Disappearing")
    func testTheRowRecordsAppearingAndDisappearing() {
        let screen = makeScreen()
        let exerciseBox = Box(exercise())
        let setBox = Box(set())
        let delegate = SetTrackerRowDelegate(
            exercise: exerciseBox.binding,
            set: setBox.binding,
            lastSet: nil
        )

        screen.presenter.onViewAppear(delegate: delegate)
        screen.presenter.onViewDisappear(delegate: delegate)

        #expect(screen.interactor.trackedScreenEventNames == ["SetTrackerRowView_Appear"])
        #expect(screen.interactor.trackedEventNames == ["SetTrackerRowView_Disappear"])
    }
}

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

// Every screen inside the live workout tracker is covered here, so the fixtures they share — a
// set, an exercise, the box that stands in for a `Binding` — are written once rather than six
// times. Six suites of them run past the file limit.
// swiftlint:disable file_length

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

/// The sheet that picks which set-up of an exercise is being used — the cable-and-rope version of
/// a pushdown rather than the bar version.
///
/// Its risk is entirely in where the list of set-ups comes from. New sessions carry their own copy;
/// sessions logged before that was stored have to be matched back to the exercise library, which
/// may not have loaded yet. Getting that wrong shows an empty sheet or a spinner that never stops.
@MainActor
struct WorkoutEquipmentSheetPresenterTests {

    private final class Interactor: SpyGlobalInteractor, WorkoutExerciseEquipmentSheetInteractor {
        var userId: String? = "user-1"
        var workoutGymProfile: GymProfileModel?
        var allExercises: [ExerciseModel] = []
    }

    /// `WorkoutExerciseEquipmentSheetRouter` adds nothing to `GlobalRouter`, so the dismissals both
    /// buttons perform are extension methods that never reach here. The tests assert what the
    /// buttons hand back instead.
    private final class Router: WorkoutExerciseEquipmentSheetRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    private struct Screen {
        let presenter: WorkoutExerciseEquipmentSheetPresenter
        let interactor: Interactor
    }

    private func makeScreen() -> Screen {
        let interactor = Interactor()
        return Screen(
            presenter: WorkoutExerciseEquipmentSheetPresenter(interactor: interactor, router: Router()),
            interactor: interactor
        )
    }

    private func variation(id: String) -> EquipmentVariation {
        EquipmentVariation(
            id: id,
            resistanceEquipment: [EquipmentRef(kind: .freeWeight, id: "dumbbells")],
            supportEquipment: [EquipmentRef(kind: .supportEquipment, id: "flat_bench")]
        )
    }

    private func exercise(
        templateId: String = "template-1",
        chosenVariationId: String? = nil,
        variations: [EquipmentVariation] = []
    ) -> WorkoutExerciseModel {
        WorkoutExerciseModel(
            id: "exercise-1",
            authorId: "user-1",
            templateId: templateId,
            name: "Bench Press",
            trackingMode: .weightReps,
            index: 1,
            sets: [],
            chosenVariationId: chosenVariationId,
            equipmentVariations: variations
        )
    }

    private func exerciseModel(id: String, name: String, variations: [EquipmentVariation]) -> ExerciseModel {
        ExerciseModel(
            id: id,
            authorId: "user-1",
            name: name,
            trackableMetrics: [.weight, .reps],
            type: .compoundUpper,
            laterality: .bilateral,
            muscleGroups: [:],
            isBodyweight: false,
            equipmentVariations: variations,
            rangeOfMotion: 1,
            stability: 1,
            bodyWeightContribution: 0,
            alternateNames: []
        )
    }

    @Test("Test The Sessions Own Set Ups Are Listed")
    func testTheSessionsOwnSetUpsAreListed() async {
        let screen = makeScreen()

        await screen.presenter.loadVariations(
            exercise: exercise(variations: [variation(id: "v1"), variation(id: "v2")])
        )

        #expect(screen.presenter.variationItems.map(\.id) == ["v1", "v2"])
        #expect(screen.presenter.variationItems.map(\.name) == ["Variation 1", "Variation 2"])
        #expect(screen.presenter.isLoading == false)
        #expect(screen.presenter.loadError == nil)
    }

    /// Equipment is stored as a reference, not a label, so the sheet has to resolve each one
    /// against the catalog. A row reading "freeWeight:dumbbell" would be unreadable.
    @Test("Test Equipment Is Shown By Name Not By Reference")
    func testEquipmentIsShownByNameNotByReference() async {
        let screen = makeScreen()

        await screen.presenter.loadVariations(exercise: exercise(variations: [variation(id: "v1")]))

        let item = screen.presenter.variationItems.first
        #expect(item?.resistanceSummary == "Dumbbells")
        #expect(item?.supportSummary == "Flat Bench")
    }

    @Test("Test A Set Up With No Equipment Reads As None")
    func testASetUpWithNoEquipmentReadsAsNone() async {
        let screen = makeScreen()
        let bare = EquipmentVariation(id: "v1", resistanceEquipment: [], supportEquipment: [])

        await screen.presenter.loadVariations(exercise: exercise(variations: [bare]))

        #expect(screen.presenter.variationItems.first?.resistanceSummary == "None")
        #expect(screen.presenter.variationItems.first?.supportSummary == "None")
    }

    /// Opening the sheet on an exercise that has never had a set-up chosen lands on the first one,
    /// so pressing Done immediately records something rather than nothing.
    @Test("Test The First Set Up Is Selected When None Was Chosen")
    func testTheFirstSetUpIsSelectedWhenNoneWasChosen() async {
        let screen = makeScreen()

        await screen.presenter.loadVariations(
            exercise: exercise(variations: [variation(id: "v1"), variation(id: "v2")])
        )

        #expect(screen.presenter.chosenVariationId == "v1")
    }

    @Test("Test An Existing Choice Is Kept")
    func testAnExistingChoiceIsKept() async {
        let screen = makeScreen()

        await screen.presenter.loadVariations(
            exercise: exercise(chosenVariationId: "v2", variations: [variation(id: "v1"), variation(id: "v2")])
        )

        #expect(screen.presenter.chosenVariationId == "v2")
    }

    /// Sessions logged before set-ups were stored on the session have nothing to show, so the
    /// sheet falls back to the exercise library.
    @Test("Test An Old Session Falls Back To The Exercise Library")
    func testAnOldSessionFallsBackToTheExerciseLibrary() async {
        let screen = makeScreen()
        screen.interactor.allExercises = [
            exerciseModel(id: "template-1", name: "Bench Press", variations: [variation(id: "lib-1")])
        ]

        await screen.presenter.loadVariations(exercise: exercise())

        #expect(screen.presenter.variationItems.map(\.id) == ["lib-1"])
    }

    /// An exercise re-seeded under a new id leaves old sessions pointing at a template that no
    /// longer exists, so the name is the last way back to its set-ups.
    @Test("Test A Stale Template Id Is Matched By Name")
    func testAStaleTemplateIdIsMatchedByName() async {
        let screen = makeScreen()
        screen.interactor.allExercises = [
            exerciseModel(id: "system-bench-v2", name: "bench press", variations: [variation(id: "lib-1")])
        ]

        await screen.presenter.loadVariations(exercise: exercise(templateId: "gone"))

        #expect(screen.presenter.variationItems.map(\.id) == ["lib-1"])
    }

    /// Nothing to show is an explained empty sheet, not a spinner — a spinner that never stops is
    /// indistinguishable from a sheet still loading.
    @Test("Test An Exercise With No Set Ups Explains Itself")
    func testAnExerciseWithNoSetUpsExplainsItself() async {
        let screen = makeScreen()
        screen.interactor.allExercises = [
            exerciseModel(id: "template-1", name: "Bench Press", variations: [])
        ]

        await screen.presenter.loadVariations(exercise: exercise())

        #expect(screen.presenter.isLoading == false)
        #expect(screen.presenter.loadError != nil)
        #expect(screen.presenter.variationItems.isEmpty)
        #expect(screen.interactor.trackedEventNames.contains(
            "WorkoutExerciseEquipmentSheetView_LoadVariations_Fail"
        ))
    }

    @Test("Test Choosing A Set Up And Pressing Done Hands It Back")
    func testChoosingASetUpAndPressingDoneHandsItBack() async {
        let screen = makeScreen()
        await screen.presenter.loadVariations(
            exercise: exercise(variations: [variation(id: "v1"), variation(id: "v2")])
        )
        var selected: [String?] = []

        screen.presenter.onSelectVariation(id: "v2")
        screen.presenter.onDonePressed { selected.append($0) }

        #expect(selected == ["v2"])
    }

    /// Backing out changes nothing. Cancel only dismisses — a `GlobalRouter` extension this
    /// double cannot see — so what the test holds is that the choice made on screen was never
    /// handed anywhere, leaving the exercise on the set-up it arrived with.
    @Test("Test Cancelling Keeps The Choice On The Sheet")
    func testCancellingKeepsTheChoiceOnTheSheet() async {
        let screen = makeScreen()
        await screen.presenter.loadVariations(
            exercise: exercise(chosenVariationId: "v1", variations: [variation(id: "v1"), variation(id: "v2")])
        )

        screen.presenter.onSelectVariation(id: "v2")
        screen.presenter.onCancelPressed()

        #expect(screen.presenter.chosenVariationId == "v2")
    }
}

/// The warm-up sheet: the same set rows, filtered to the warm-up sets of one exercise.
///
/// It owns no logic of its own — the exercise arrives already bound — so what matters is that it
/// is recorded in analytics under its own name and that its dismissal is safe to call.
@MainActor
struct WarmupSetsPresenterTests {

    private final class Interactor: SpyGlobalInteractor, WarmupSetsInteractor { }

    /// `WarmupSetsRouter` adds nothing to `GlobalRouter`, so `dismissScreen()` is an extension
    /// method that dispatches statically and never reaches this double.
    private final class Router: WarmupSetsRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    @MainActor
    private final class Box {
        var value: WorkoutExerciseModel

        init(_ value: WorkoutExerciseModel) {
            self.value = value
        }

        var binding: Binding<WorkoutExerciseModel> {
            Binding(
                get: { MainActor.assumeIsolated { self.value } },
                set: { newValue in MainActor.assumeIsolated { self.value = newValue } }
            )
        }
    }

    private func exercise() -> WorkoutExerciseModel {
        WorkoutExerciseModel(
            id: "exercise-1",
            authorId: "user-1",
            templateId: "template-1",
            name: "Bench Press",
            trackingMode: .weightReps,
            index: 1,
            sets: []
        )
    }

    @Test("Test The Warmup Sheet Holds The Exercise It Was Opened With")
    func testTheWarmupSheetHoldsTheExerciseItWasOpenedWith() {
        let model = exercise()
        let presenter = WarmupSetsPresenter(
            interactor: Interactor(),
            router: Router(),
            exercise: model
        )

        #expect(presenter.exercise.id == model.id)
        #expect(presenter.exercise.templateId == model.templateId)
    }

    @Test("Test The Warmup Sheet Records Appearing And Disappearing")
    func testTheWarmupSheetRecordsAppearingAndDisappearing() {
        let interactor = Interactor()
        let presenter = WarmupSetsPresenter(interactor: interactor, router: Router(), exercise: exercise())
        let box = Box(exercise())
        let delegate = WarmupSetsDelegate(exercise: box.binding)

        presenter.onViewAppear(delegate: delegate)
        presenter.onViewDisappear(delegate: delegate)

        #expect(interactor.trackedScreenEventNames == ["WarmupSetsView_Appear"])
        #expect(interactor.trackedEventNames == ["WarmupSetsView_Disappear"])
    }

    /// Closing the sheet leaves the exercise exactly as it was — the sets were edited in place
    /// through the binding, so dismissal must not be a save or a revert.
    @Test("Test Dismissing The Warmup Sheet Changes Nothing")
    func testDismissingTheWarmupSheetChangesNothing() {
        let interactor = Interactor()
        let presenter = WarmupSetsPresenter(interactor: interactor, router: Router(), exercise: exercise())
        let before = presenter.exercise

        presenter.onDismissPressed()

        #expect(presenter.exercise == before)
        #expect(interactor.trackedEventNames.isEmpty)
    }
}

/// The picker for swapping one exercise for another mid-workout — the rack is taken, so something
/// else has to do.
///
/// A swap rewrites what the session says was trained, so the only thing that must hold is that the
/// exercise handed back is the one that was tapped.
@MainActor
struct SwapExercisePickerPresenterTests {

    private final class Interactor: SpyGlobalInteractor, SwapExercisePickerInteractor {
        var allExercises: [ExerciseModel] = []
    }

    /// `SwapExercisePickerRouter` adds nothing to `GlobalRouter`, so the dismissal both paths
    /// perform is an extension method that never reaches this double.
    private final class Router: SwapExercisePickerRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    private func exerciseModel(id: String, name: String) -> ExerciseModel {
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

    private func makePresenter(
        exercises: [ExerciseModel],
        onSelect: @escaping (ExerciseModel) -> Void = { _ in }
    ) -> SwapExercisePickerPresenter {
        let interactor = Interactor()
        interactor.allExercises = exercises
        return SwapExercisePickerPresenter(interactor: interactor, router: Router(), onSelect: onSelect)
    }

    @Test("Test An Empty Search Shows Everything")
    func testAnEmptySearchShowsEverything() {
        let presenter = makePresenter(exercises: [
            exerciseModel(id: "1", name: "Bench Press"),
            exerciseModel(id: "2", name: "Incline Press")
        ])

        #expect(presenter.filteredExercises.count == 2)
    }

    /// Searching is by what the user is looking at, not by how it is capitalised, and matches
    /// anywhere in the name so "press" finds the inclines too.
    @Test("Test Searching Matches Anywhere In The Name Ignoring Case")
    func testSearchingMatchesAnywhereInTheNameIgnoringCase() {
        let presenter = makePresenter(exercises: [
            exerciseModel(id: "1", name: "Bench Press"),
            exerciseModel(id: "2", name: "Incline Press"),
            exerciseModel(id: "3", name: "Barbell Row")
        ])

        presenter.searchText = "press"

        #expect(presenter.filteredExercises.map(\.id) == ["1", "2"])
    }

    @Test("Test A Search That Matches Nothing Shows Nothing")
    func testASearchThatMatchesNothingShowsNothing() {
        let presenter = makePresenter(exercises: [exerciseModel(id: "1", name: "Bench Press")])

        presenter.searchText = "deadlift"

        #expect(presenter.filteredExercises.isEmpty)
    }

    /// The exercise tapped is the exercise the session gets. Handing back the wrong one logs the
    /// workout against a movement that was never performed.
    @Test("Test The Tapped Exercise Is Handed Back")
    func testTheTappedExerciseIsHandedBack() {
        var selected: [String] = []
        let presenter = makePresenter(
            exercises: [exerciseModel(id: "1", name: "Bench Press")],
            onSelect: { selected.append($0.id) }
        )

        presenter.onExerciseSelected(exerciseModel(id: "2", name: "Incline Press"))

        #expect(selected == ["2"])
    }

    /// Backing out of the picker swaps nothing.
    @Test("Test Dismissing The Picker Swaps Nothing")
    func testDismissingThePickerSwapsNothing() {
        var selected: [String] = []
        let presenter = makePresenter(
            exercises: [exerciseModel(id: "1", name: "Bench Press")],
            onSelect: { selected.append($0.id) }
        )

        presenter.onDismissPressed()

        #expect(selected.isEmpty)
    }
}

/// The exercise card in the tracker — the header, the set list and the menu behind it.
///
/// Its presenter is a shell: the view drives everything through the delegate, and nothing here
/// reads or writes the session. The one thing worth holding is that constructing a card is free
/// of side effects, because one is built per exercise every time the workout list redraws.
@MainActor
struct ExerciseTrackerPresenterTests {

    private final class Interactor: SpyGlobalInteractor, ExerciseTrackerInteractor { }

    private final class Router: ExerciseTrackerRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    @Test("Test Building An Exercise Card Has No Side Effects")
    func testBuildingAnExerciseCardHasNoSideEffects() {
        let interactor = Interactor()

        _ = ExerciseTrackerPresenter(interactor: interactor, router: Router())

        #expect(interactor.trackedEventNames.isEmpty)
        #expect(interactor.trackedScreenEventNames.isEmpty)
        #expect(interactor.playedHaptics.isEmpty)
    }
}

/// The notes sheet on a workout — free text saved against the session.
///
/// The text is edited straight through a binding the view owns, so the presenter's only job is to
/// close the sheet without touching what was typed.
@MainActor
struct WorkoutNotesPresenterTests {

    private final class Interactor: WorkoutNotesInteractor { }

    /// `WorkoutNotesRouter` adds nothing to `GlobalRouter`, so `dismissScreen()` is an extension
    /// method and never reaches this double. What the test can hold is that closing the sheet does
    /// not disturb the notes.
    private final class Router: WorkoutNotesRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    @MainActor
    private final class Box {
        var value: String

        init(_ value: String) {
            self.value = value
        }

        var binding: Binding<String> {
            Binding(
                get: { MainActor.assumeIsolated { self.value } },
                set: { newValue in MainActor.assumeIsolated { self.value = newValue } }
            )
        }
    }

    /// Closing the sheet is not a discard — what was typed stays typed, and saving is the view's
    /// own `onSave`, run separately.
    @Test("Test Closing The Notes Sheet Keeps What Was Typed")
    func testClosingTheNotesSheetKeepsWhatWasTyped() {
        let presenter = WorkoutNotesPresenter(interactor: Interactor(), router: Router())
        let box = Box("Felt strong, bumped the top set.")
        let delegate = WorkoutNotesDelegate(notes: box.binding, onSave: { })

        presenter.onDismissPressed()

        #expect(box.value == "Felt strong, bumped the top set.")
        #expect(delegate.notes.wrappedValue == "Felt strong, bumped the top set.")
    }
}

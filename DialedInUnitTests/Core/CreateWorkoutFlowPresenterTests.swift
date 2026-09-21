//
//  CreateWorkoutFlowPresenterTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 21/09/2026.
//

import Testing
import Foundation
import SwiftUI
@testable import DialedIn

/// Holds a list of template exercises so the presenters' `Binding`-taking APIs can be driven
/// without a view and read back. Main-actor isolated so it is `Sendable`, as `Binding` requires.
@MainActor
private final class CreateWorkoutFlowExerciseBox {
    var value: [WorkoutTemplateExercise]

    init(_ value: [WorkoutTemplateExercise] = []) {
        self.value = value
    }

    var binding: Binding<[WorkoutTemplateExercise]> {
        Binding(
            get: { MainActor.assumeIsolated { self.value } },
            set: { newValue in MainActor.assumeIsolated { self.value = newValue } }
        )
    }
}

/// Stands in for whoever asked for a workout to be built: the start-a-workout flow hands a
/// callback down the wizard and expects the finished template back through it.
@MainActor
private final class CreateWorkoutFlowCreationSpy {
    private(set) var created: [WorkoutTemplateModel] = []

    var callback: @Sendable (WorkoutTemplateModel) -> Void {
        { workout in MainActor.assumeIsolated { self.created.append(workout) } }
    }
}

/// An exercise targeting whichever muscles the test cares about.
@MainActor
private func flowExercise(
    id: String = UUID().uuidString,
    name: String = "Bench Press",
    muscles: [Muscles: MuscleTargetType] = [.chest: .primary]
) -> ExerciseModel {
    ExerciseModel(
        id: id,
        authorId: "author-1",
        name: name,
        trackableMetrics: [.weight, .reps],
        type: .compoundUpper,
        laterality: .bilateral,
        muscleGroups: muscles,
        isBodyweight: false,
        rangeOfMotion: 4,
        stability: 5,
        bodyWeightContribution: 0,
        alternateNames: []
    )
}

/// A template exercise whose sets are numbered the way the set-target screen numbers them.
@MainActor
private func flowTemplateExercise(
    id: String = UUID().uuidString,
    exercise: ExerciseModel,
    setCount: Int = 1
) -> WorkoutTemplateExercise {
    WorkoutTemplateExercise(
        id: id,
        exercise: exercise,
        setTargets: (1...max(setCount, 1)).prefix(setCount).map { SetTarget(setNumber: $0) },
        setRestTimers: false
    )
}

// MARK: - Step 1: the splash that starts the wizard

/// The first screen of building a workout: an image, a blurb and a Continue button. It holds no
/// state, so the only thing it can lose is the callback the caller handed in — the route by which
/// a workout built to "start now" gets back to the screen that asked for it.
@MainActor
struct WorkoutBuildStartPresenterTests {

    private final class Interactor: SpyGlobalInteractor, CreateWorkoutInteractor { }

    /// `cancel()` goes through `dismissScreen()`, a `GlobalRouter` extension method rather than a
    /// requirement of `CreateWorkoutRouter`. It dispatches statically and never reaches this
    /// double, so there is nothing to record and nothing to assert.
    private final class Router: CreateWorkoutRouter {
        let router: AnyRouter = TestRouting.anyRouter
        private(set) var nameDelegates: [NameWorkoutDelegate] = []

        func showNameWorkoutView(delegate: NameWorkoutDelegate) {
            nameDelegates.append(delegate)
        }
    }

    private func makeScreen() -> (CreateWorkoutPresenter, Router) {
        let router = Router()
        return (CreateWorkoutPresenter(interactor: Interactor(), router: router), router)
    }

    /// Losing the callback here is silent until four hops later, when the built workout has
    /// nowhere to go and never starts.
    @Test("Test Continuing Carries The Creation Callback To The Naming Step")
    func testContinuingCarriesTheCreationCallbackToTheNamingStep() {
        let (presenter, router) = makeScreen()
        let spy = CreateWorkoutFlowCreationSpy()

        presenter.onContinuePressed(delegate: CreateWorkoutDelegate(onWorkoutCreated: spy.callback))
        router.nameDelegates.first?.onWorkoutCreated?(WorkoutTemplateModel(authorId: "user-1", name: "Push"))

        #expect(router.nameDelegates.count == 1)
        #expect(spy.created.map(\.name) == ["Push"])
    }

    /// Building a workout from the library has no caller waiting on it, and the next step has to
    /// be told that rather than handed something that makes it behave like the start flow.
    @Test("Test No Callback Is Invented When There Was None")
    func testNoCallbackIsInventedWhenThereWasNone() {
        let (presenter, router) = makeScreen()

        presenter.onContinuePressed(delegate: CreateWorkoutDelegate())

        #expect(router.nameDelegates.first?.onWorkoutCreated == nil)
    }
}

// MARK: - Step 2: naming it

/// Naming the workout. The name typed here is the one the workout is saved under three screens
/// later, so it has to travel intact, and whitespace alone must not become a nameless workout in
/// the user's library.
@MainActor
struct WorkoutBuildNamePresenterTests {

    private final class Interactor: SpyGlobalInteractor, NameWorkoutInteractor {
        var currentUser: UserModel? = UserModel(userId: "user-1")

        func saveWorkoutTemplate(workoutTemplate: WorkoutTemplateModel, image: PlatformImage?) async throws { }

        func generateImage(input: String) async throws -> UIImage {
            UIImage()
        }
    }

    private final class Router: NameWorkoutRouter {
        let router: AnyRouter = TestRouting.anyRouter
        private(set) var gymDelegates: [ChooseGymProfileDelegate] = []

        func showChooseGymProfileView(delegate: ChooseGymProfileDelegate) {
            gymDelegates.append(delegate)
        }
    }

    private func makeScreen() -> (NameWorkoutPresenter, Router) {
        let router = Router()
        return (NameWorkoutPresenter(interactor: Interactor(), router: router), router)
    }

    @Test("Test A Workout Cannot Be Named Nothing")
    func testAWorkoutCannotBeNamedNothing() {
        let (presenter, _) = makeScreen()

        presenter.workoutName = "   \n "
        #expect(!presenter.canSave)

        presenter.workoutName = "Push Day"
        #expect(presenter.canSave)
    }

    @Test("Test The Typed Name And The Callback Reach The Gym Step")
    func testTheTypedNameAndTheCallbackReachTheGymStep() {
        let (presenter, router) = makeScreen()
        let spy = CreateWorkoutFlowCreationSpy()
        presenter.workoutName = "Push Day"

        presenter.onContinuePressed(delegate: NameWorkoutDelegate(onWorkoutCreated: spy.callback))
        router.gymDelegates.first?.onWorkoutCreated?(WorkoutTemplateModel(authorId: "user-1", name: "Push Day"))

        #expect(router.gymDelegates.first?.name == "Push Day")
        #expect(spy.created.count == 1)
    }
}

// MARK: - Step 3: choosing where it will be done

/// Choosing which gym the workout belongs to. The screen only lists what the interactor holds, so
/// the risk is all in the hop: the name from the previous step, the gym just picked and the
/// creation callback have to arrive together at the define step.
@MainActor
struct WorkoutBuildGymChoicePresenterTests {

    private final class Interactor: SpyGlobalInteractor, ChooseGymProfileInteractor {
        var userId: String? = "user-1"
        var currentUser: UserModel? = UserModel(userId: "user-1")
        var favouriteGymProfile: GymProfileModel?
        var gymProfiles: [GymProfileModel] = []
        private(set) var deletedProfileIds: [String] = []

        func deleteGymProfile(_ profileId: String) async throws {
            deletedProfileIds.append(profileId)
        }
    }

    private final class Router: ChooseGymProfileRouter {
        let router: AnyRouter = TestRouting.anyRouter
        private(set) var defineDelegates: [DefineWorkoutWrapperDelegate] = []

        func showDefineWorkoutWrapperView(delegate: DefineWorkoutWrapperDelegate) {
            defineDelegates.append(delegate)
        }
    }

    private struct Screen {
        let presenter: ChooseGymProfilePresenter
        let interactor: Interactor
        let router: Router
    }

    private func makeScreen() -> Screen {
        let interactor = Interactor()
        let router = Router()
        return Screen(
            presenter: ChooseGymProfilePresenter(interactor: interactor, router: router),
            interactor: interactor,
            router: router
        )
    }

    private func profile(_ id: String, name: String) -> GymProfileModel {
        GymProfileModel(id: id, authorId: "user-1", name: name)
    }

    @Test("Test The Gyms On File Are Listed")
    func testTheGymsOnFileAreListed() {
        let screen = makeScreen()
        screen.interactor.gymProfiles = [profile("gym-1", name: "Home Gym"), profile("gym-2", name: "Commercial")]

        #expect(screen.presenter.gymProfiles.map(\.name) == ["Home Gym", "Commercial"])
        #expect(screen.presenter.numGyms == 2)
    }

    /// The favourite is read off the stored profile rather than off the list, so it has to keep
    /// pointing at the gym the user actually favourited.
    @Test("Test The Favourite Gym Is Taken From The Profile")
    func testTheFavouriteGymIsTakenFromTheProfile() {
        let screen = makeScreen()
        screen.interactor.currentUser = UserModel(userId: "user-1", submittedFavouriteGymProfileId: "gym-2")
        screen.interactor.favouriteGymProfile = profile("gym-2", name: "Commercial")

        #expect(screen.presenter.favouriteGymProfileId == "gym-2")
        #expect(screen.presenter.favouriteGymProfile?.name == "Commercial")
    }

    /// The name has come two screens by now and is not shown on this one, which is exactly what
    /// makes it easy to drop here.
    @Test("Test The Name Gym And Callback Reach The Define Step")
    func testTheNameGymAndCallbackReachTheDefineStep() {
        let screen = makeScreen()
        let spy = CreateWorkoutFlowCreationSpy()

        screen.presenter.onGymProfilePressed(
            name: "Push Day",
            profile: profile("gym-1", name: "Home Gym"),
            delegate: ChooseGymProfileDelegate(name: "Push Day", onWorkoutCreated: spy.callback)
        )
        screen.router.defineDelegates.first?.onWorkoutCreated?(WorkoutTemplateModel(authorId: "user-1", name: "Push Day"))

        #expect(screen.router.defineDelegates.first?.name == "Push Day")
        #expect(screen.router.defineDelegates.first?.gymProfile.id == "gym-1")
        #expect(spy.created.count == 1)
    }

    @Test("Test Appearing Is Tracked As A Screen View")
    func testAppearingIsTrackedAsAScreenView() {
        let screen = makeScreen()

        screen.presenter.onViewAppear()
        screen.presenter.onViewDisappear()

        #expect(screen.interactor.trackedScreenEventNames == ["GymProfilesView_Appear"])
        #expect(screen.interactor.trackedEventNames == ["GymProfilesView_Disappear"])
    }
}

// MARK: - Step 4: the exercises and their targets

/// The screen where the workout is assembled: exercises added, removed and given set targets,
/// with a volume summary per muscle. The list is mirrored out of a `Binding` so SwiftUI notices
/// edits, and a one-way mirror would silently lose what the user added. The summary is the only
/// arithmetic here — it tells the user whether the workout is balanced, so an assisting muscle
/// counted as a worked one makes the workout read harder than it is.
@MainActor
struct WorkoutBuildDefinePresenterTests {

    private final class Interactor: SpyGlobalInteractor, DefineWorkoutInteractor {
        var currentUser: UserModel? = UserModel(userId: "user-1")

        func saveWorkoutTemplate(workoutTemplate: WorkoutTemplateModel, image: PlatformImage?) async throws { }
    }

    private final class Router: DefineWorkoutRouter {
        let router: AnyRouter = TestRouting.anyRouter
        private(set) var pickerDelegates: [ExercisesPickerDelegate] = []
        private(set) var setTargetDelegates: [SetTargetDelegate] = []

        func showExercisesPickerView(delegate: ExercisesPickerDelegate) {
            pickerDelegates.append(delegate)
        }

        func showSetTargetView(delegate: SetTargetDelegate) {
            setTargetDelegates.append(delegate)
        }
    }

    private struct Screen {
        let presenter: DefineWorkoutPresenter
        let interactor: Interactor
        let router: Router
        let box: CreateWorkoutFlowExerciseBox
    }

    private func makeScreen(exercises: [WorkoutTemplateExercise] = []) -> Screen {
        let interactor = Interactor()
        let router = Router()
        let box = CreateWorkoutFlowExerciseBox(exercises)
        return Screen(
            presenter: DefineWorkoutPresenter(interactor: interactor, router: router, exercises: box.binding),
            interactor: interactor,
            router: router,
            box: box
        )
    }

    // MARK: The list and the binding behind it

    /// The parent owns the list, and a mirror that never writes back means the user removes an
    /// exercise, watches it disappear, and finds it again in the workout that gets saved. The same
    /// exercise can also appear twice in a workout — rows are told apart by their own id rather
    /// than by the exercise they hold — so removing one copy leaves the other standing.
    @Test("Test Removing An Exercise Reaches The Parent")
    func testRemovingAnExerciseReachesTheParent() {
        let bench = flowExercise(id: "bench", name: "Bench Press")
        let screen = makeScreen(exercises: [
            flowTemplateExercise(id: "a", exercise: bench),
            flowTemplateExercise(id: "b", exercise: bench),
            flowTemplateExercise(id: "c", exercise: flowExercise(name: "Row"))
        ])

        screen.presenter.removeExercise(exercise: screen.presenter.exercises[0])

        #expect(screen.presenter.exercises.map(\.id) == ["b", "c"])
        #expect(screen.box.value.map(\.id) == ["b", "c"])
    }

    // MARK: Adding exercises

    /// The picker writes through a binding into this screen's list: what is ticked there has to
    /// land in the workout and in the parent behind it, alongside what was already in it.
    @Test("Test Exercises Picked In The Picker Land In The Workout")
    func testExercisesPickedInThePickerLandInTheWorkout() {
        let bench = flowTemplateExercise(exercise: flowExercise(name: "Bench Press"))
        let screen = makeScreen(exercises: [bench])

        screen.presenter.onAddExercisePressed()
        screen.router.pickerDelegates.first?.addedExercises.wrappedValue.append(
            flowTemplateExercise(exercise: flowExercise(name: "Squat"))
        )

        #expect(screen.presenter.exercises.map(\.exercise.name) == ["Bench Press", "Squat"])
        #expect(screen.box.value.map(\.exercise.name) == ["Bench Press", "Squat"])
    }

    // MARK: Editing an exercise's targets

    /// The set-target sheet edits through the binding it is handed, so that binding has to point
    /// at the row that was tapped — otherwise the targets land on a different exercise.
    @Test("Test Set Targets Written By The Sheet Reach The Tapped Exercise")
    func testSetTargetsWrittenByTheSheetReachTheTappedExercise() {
        let bench = flowTemplateExercise(id: "a", exercise: flowExercise(name: "Bench Press"))
        let screen = makeScreen(exercises: [bench])
        let box = CreateWorkoutFlowExerciseBox([bench])

        screen.presenter.onExercisePressed(exercise: Binding(
            get: { MainActor.assumeIsolated { box.value[0] } },
            set: { newValue in MainActor.assumeIsolated { box.value[0] = newValue } }
        ))
        screen.router.setTargetDelegates.first?.exercise.wrappedValue.setTargets = [
            SetTarget(setNumber: 1, minReps: 6, maxReps: 8),
            SetTarget(setNumber: 2, minReps: 6, maxReps: 8)
        ]

        #expect(box.value[0].setTargets.map(\.setNumber) == [1, 2])
        #expect(box.value[0].setTargets.first?.minReps == 6)
    }

    // MARK: The muscle summary

    /// Three sets of an exercise that works the chest directly is three chest sets; a muscle that
    /// only assists counts half, which is what stops an accessory-heavy workout reading as if it
    /// trained everything hard.
    @Test("Test Worked Muscles Count Whole Sets And Assisting Ones Half")
    func testWorkedMusclesCountWholeSetsAndAssistingOnesHalf() {
        let exercise = flowExercise(muscles: [.chest: .primary, .triceps: .secondary])
        let screen = makeScreen(exercises: [flowTemplateExercise(exercise: exercise, setCount: 3)])

        let chest = screen.presenter.targetMuscleSummaries.first { $0.muscle == .chest }
        let triceps = screen.presenter.targetMuscleSummaries.first { $0.muscle == .triceps }
        #expect(chest?.weightedTargetSets == 3)
        #expect(chest?.exerciseCount == 1)
        #expect(triceps?.weightedTargetSets == 1.5)
        #expect(triceps?.exerciseCount == 1)
    }

    /// Volume for a muscle is the sum across every exercise that hits it, weighted per exercise
    /// rather than for the workout as a whole.
    @Test("Test Volume Adds Up Across Exercises")
    func testVolumeAddsUpAcrossExercises() {
        let press = flowExercise(id: "press", muscles: [.chest: .primary, .triceps: .secondary])
        let dip = flowExercise(id: "dip", muscles: [.chest: .secondary, .triceps: .primary])
        let screen = makeScreen(exercises: [
            flowTemplateExercise(exercise: press, setCount: 4),
            flowTemplateExercise(exercise: dip, setCount: 2)
        ])

        let chest = screen.presenter.targetMuscleSummaries.first { $0.muscle == .chest }
        let triceps = screen.presenter.targetMuscleSummaries.first { $0.muscle == .triceps }
        #expect(chest?.weightedTargetSets == 5)
        #expect(chest?.exerciseCount == 2)
        #expect(triceps?.weightedTargetSets == 4)
        #expect(triceps?.exerciseCount == 2)
    }

    /// An exercise with no targets yet trains nothing, so it must inflate neither the set count
    /// nor the number of exercises credited to the muscle.
    @Test("Test An Exercise With No Targets Adds No Volume")
    func testAnExerciseWithNoTargetsAddsNoVolume() {
        let exercise = flowExercise(muscles: [.chest: .primary])
        var empty = flowTemplateExercise(exercise: exercise)
        empty.setTargets = []
        let screen = makeScreen(exercises: [flowTemplateExercise(exercise: exercise, setCount: 2), empty])

        let chest = screen.presenter.targetMuscleSummaries.first { $0.muscle == .chest }
        #expect(chest?.weightedTargetSets == 2)
        #expect(chest?.exerciseCount == 1)
    }

    /// The summary is a horizontal strip, so the same workout must not shuffle its muscles
    /// between redraws just because a dictionary was iterated.
    @Test("Test The Summary Is Ordered By Muscle Name")
    func testTheSummaryIsOrderedByMuscleName() {
        let exercise = flowExercise(muscles: [.triceps: .secondary, .chest: .primary, .frontDelts: .secondary])
        let screen = makeScreen(exercises: [flowTemplateExercise(exercise: exercise, setCount: 2)])

        #expect(screen.presenter.targetMuscleSummaries.map(\.muscle.name) == ["Chest", "Front Delts", "Triceps"])
    }

    @Test("Test Appearing Is Tracked As A Screen View")
    func testAppearingIsTrackedAsAScreenView() {
        let screen = makeScreen()

        screen.presenter.onViewAppear()
        screen.presenter.onViewDisappear()

        #expect(screen.interactor.trackedScreenEventNames == ["DefineWorkoutView_Appear"])
        #expect(screen.interactor.trackedEventNames == ["DefineWorkoutView_Disappear"])
    }
}

// MARK: - The exercise picker

/// Ticking exercises to add to the workout being defined. The picker works on a scratch list and
/// only writes into the workout on confirm, so what matters is that backing out leaves the
/// workout alone and confirming adds to it rather than replacing it.
@MainActor
struct WorkoutBuildPickerPresenterTests {

    private final class Interactor: SpyGlobalInteractor, ExercisesPickerInteractor { }

    /// `ExercisesPickerRouter` adds no requirements, and the presenter's only navigation is
    /// `dismissScreen()` — a `GlobalRouter` extension method, statically dispatched, so a double
    /// cannot observe it. The tests assert the committed list instead.
    private final class Router: ExercisesPickerRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    private struct Screen {
        let presenter: ExercisesPickerPresenter
        let box: CreateWorkoutFlowExerciseBox
    }

    private func makeScreen(existing: [WorkoutTemplateExercise] = []) -> Screen {
        let box = CreateWorkoutFlowExerciseBox(existing)
        return Screen(
            presenter: ExercisesPickerPresenter(
                interactor: Interactor(),
                router: Router(),
                delegate: ExercisesPickerDelegate(addedExercises: box.binding)
            ),
            box: box
        )
    }

    /// The row is a toggle, so pressing a ticked exercise unticks that one rather than adding a
    /// second copy of it, and leaves the rest of the selection alone.
    @Test("Test Pressing A Selected Exercise Deselects It")
    func testPressingASelectedExerciseDeselectsIt() {
        let screen = makeScreen()
        let squat = flowExercise(id: "squat", name: "Squat")

        screen.presenter.onExercisePressed(exercise: flowExercise(id: "bench", name: "Bench Press"))
        screen.presenter.onExercisePressed(exercise: squat)
        screen.presenter.onExercisePressed(exercise: flowExercise(id: "row", name: "Row"))
        screen.presenter.onExercisePressed(exercise: squat)

        #expect(screen.presenter.workingExercises.map(\.exercise.name) == ["Bench Press", "Row"])
    }

    /// Nothing reaches the workout until the user confirms, so closing the picker after tapping
    /// around must not quietly add exercises.
    @Test("Test Ticking Without Confirming Changes Nothing")
    func testTickingWithoutConfirmingChangesNothing() {
        let screen = makeScreen()

        screen.presenter.onExercisePressed(exercise: flowExercise(name: "Bench Press"))
        screen.presenter.onDismissPressed()

        #expect(screen.box.value.isEmpty)
    }

    @Test("Test Confirming Adds The Selection To The Workout")
    func testConfirmingAddsTheSelectionToTheWorkout() {
        let existing = flowTemplateExercise(exercise: flowExercise(name: "Deadlift"))
        let screen = makeScreen(existing: [existing])

        screen.presenter.onExercisePressed(exercise: flowExercise(id: "bench", name: "Bench Press"))
        screen.presenter.onExercisePressed(exercise: flowExercise(id: "squat", name: "Squat"))
        screen.presenter.onSavePressed()

        #expect(screen.box.value.map(\.exercise.name) == ["Deadlift", "Bench Press", "Squat"])
    }

    /// A newly picked exercise arrives with one set already targeted and numbered from one, so
    /// the workout can be saved without opening the target sheet at all. Rest timers are a
    /// per-exercise override the user has not asked for, so they start off.
    @Test("Test A Picked Exercise Starts With One Numbered Set")
    func testAPickedExerciseStartsWithOneNumberedSet() {
        let screen = makeScreen()

        screen.presenter.onExercisePressed(exercise: flowExercise(name: "Bench Press"))
        screen.presenter.onSavePressed()

        #expect(screen.box.value.first?.setTargets.map(\.setNumber) == [1])
        #expect(screen.box.value.first?.setRestTimers == false)
    }
}

// MARK: - The set-target sheet

/// The sheet that sets rep ranges per set for one exercise. Its presenter carries only analytics
/// and the close action — the editing lives in the view against a working copy — so that is all
/// there is to pin here.
@MainActor
struct WorkoutBuildSetTargetPresenterTests {

    private final class Interactor: SpyGlobalInteractor, SetTargetInteractor { }

    /// `SetTargetRouter` has no requirements, and `onDismissPressed()` goes through
    /// `dismissScreen()`, a `GlobalRouter` extension method that dispatches statically and never
    /// reaches this double. There is nothing to record.
    private final class Router: SetTargetRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    private func makeScreen() -> (SetTargetPresenter, Interactor) {
        let interactor = Interactor()
        return (SetTargetPresenter(interactor: interactor, router: Router()), interactor)
    }

    @Test("Test Appearing And Leaving Are Tracked Separately")
    func testAppearingAndLeavingAreTrackedSeparately() {
        let (presenter, interactor) = makeScreen()

        presenter.onViewAppear()
        presenter.onViewDisappear()

        #expect(interactor.trackedScreenEventNames == ["SetTargetView_Appear"])
        #expect(interactor.trackedEventNames == ["SetTargetView_Disappear"])
    }
}

// MARK: - Step 5: turning it into a workout

/// The wrapper around the define screen, which owns the Save (or Start Workout) button and turns
/// everything the wizard gathered into a `WorkoutTemplateModel`. It is the last chance to lose
/// what the user chose: the name from step two, the gym from step three and the exercises from
/// step four all have to reach the saved template. It also forks — a workout built to start now
/// is handed back to its caller, while one built from the library is saved outright.
@MainActor
struct WorkoutBuildWrapperPresenterTests {

    private final class Interactor: SpyGlobalInteractor, DefineWorkoutWrapperInteractor {
        var currentUser: UserModel? = UserModel(userId: "user-1")
        var saveError: Error?
        private(set) var savedTemplates: [WorkoutTemplateModel] = []

        func saveWorkoutTemplate(workoutTemplate: WorkoutTemplateModel, image: PlatformImage?) async throws {
            if let saveError {
                throw saveError
            }
            savedTemplates.append(workoutTemplate)
        }
    }

    /// `DefineWorkoutWrapperRouter` adds no requirements: the confirm path uses `showAlert`,
    /// `showSimpleAlert` and `dismissEnvironment`, all `GlobalRouter` extension methods that
    /// dispatch statically and never reach this double. The tests assert what was saved and what
    /// was handed back instead.
    private final class Router: DefineWorkoutWrapperRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    private struct Screen {
        let presenter: DefineWorkoutWrapperPresenter
        let interactor: Interactor
    }

    private func makeScreen() -> Screen {
        let interactor = Interactor()
        return Screen(
            presenter: DefineWorkoutWrapperPresenter(interactor: interactor, router: Router()),
            interactor: interactor
        )
    }

    private func delegate(
        name: String = "Push Day",
        gymId: String = "gym-1",
        onWorkoutCreated: (@Sendable (WorkoutTemplateModel) -> Void)? = nil
    ) -> DefineWorkoutWrapperDelegate {
        DefineWorkoutWrapperDelegate(
            name: name,
            gymProfile: GymProfileModel(id: gymId, authorId: "user-1", name: "Home Gym"),
            onWorkoutCreated: onWorkoutCreated
        )
    }

    // MARK: Saving from the library flow

    @Test("Test The Workout Is Saved Under The Name The User Typed")
    func testTheWorkoutIsSavedUnderTheNameTheUserTyped() async {
        let screen = makeScreen()

        screen.presenter.onConfirmPressed(delegate: delegate(name: "Leg Day"))

        #expect(await TestManagers.eventually { !screen.interactor.savedTemplates.isEmpty })
        #expect(screen.interactor.savedTemplates.first?.name == "Leg Day")
        #expect(screen.interactor.savedTemplates.first?.authorId == "user-1")
    }

    /// The gym is chosen in its own step of the wizard and is what the tracker later uses to work
    /// out which equipment is to hand, so a template saved without it sends the user into a
    /// workout that does not know where it is being done.
    @Test("Test The Chosen Gym Is Saved With The Workout")
    func testTheChosenGymIsSavedWithTheWorkout() async {
        let screen = makeScreen()

        screen.presenter.onConfirmPressed(delegate: delegate(gymId: "gym-7"))

        #expect(await TestManagers.eventually { !screen.interactor.savedTemplates.isEmpty })
        #expect(screen.interactor.savedTemplates.first?.gymProfileId == "gym-7")
    }

    @Test("Test The Exercises Assembled On The Screen Are Saved")
    func testTheExercisesAssembledOnTheScreenAreSaved() async {
        let screen = makeScreen()
        screen.presenter.exercises = [
            flowTemplateExercise(exercise: flowExercise(name: "Squat"), setCount: 3),
            flowTemplateExercise(exercise: flowExercise(name: "Leg Press"), setCount: 2)
        ]

        screen.presenter.onConfirmPressed(delegate: delegate())

        #expect(await TestManagers.eventually { !screen.interactor.savedTemplates.isEmpty })
        let saved = screen.interactor.savedTemplates.first
        #expect(saved?.exercises.map(\.exercise.name) == ["Squat", "Leg Press"])
        #expect(saved?.exercises.first?.setTargets.map(\.setNumber) == [1, 2, 3])
    }

    /// Without a signed-in user there is no author to save the workout under, so the screen does
    /// nothing rather than writing an ownerless template.
    @Test("Test Nothing Is Saved Without A Signed In User")
    func testNothingIsSavedWithoutASignedInUser() async {
        let screen = makeScreen()
        screen.interactor.currentUser = nil

        screen.presenter.onConfirmPressed(delegate: delegate())

        let saved = await TestManagers.eventually(timeout: .milliseconds(400)) { !screen.interactor.savedTemplates.isEmpty }
        #expect(!saved)
    }

    /// A save that fails raises an alert rather than crashing or pretending to have worked. The
    /// alert is a `GlobalRouter` extension and cannot be observed, so what is checked is that the
    /// failure is contained and nothing is recorded as saved.
    @Test("Test A Failed Save Is Survived")
    func testAFailedSaveIsSurvived() async {
        let screen = makeScreen()
        screen.interactor.saveError = URLError(.notConnectedToInternet)

        screen.presenter.onConfirmPressed(delegate: delegate())

        let saved = await TestManagers.eventually(timeout: .milliseconds(400)) { !screen.interactor.savedTemplates.isEmpty }
        #expect(!saved)
    }

    // MARK: Building a workout to start right now

    /// In the start-a-workout flow the template is handed straight back to the caller so the
    /// session can begin, carrying everything the wizard collected.
    @Test("Test A Workout Built To Start Is Handed Back To Its Caller")
    func testAWorkoutBuiltToStartIsHandedBackToItsCaller() {
        let screen = makeScreen()
        let spy = CreateWorkoutFlowCreationSpy()
        screen.presenter.exercises = [flowTemplateExercise(exercise: flowExercise(name: "Squat"), setCount: 3)]

        screen.presenter.onConfirmPressed(delegate: delegate(name: "Leg Day", gymId: "gym-7", onWorkoutCreated: spy.callback))

        #expect(spy.created.count == 1)
        #expect(spy.created.first?.name == "Leg Day")
        #expect(spy.created.first?.gymProfileId == "gym-7")
        #expect(spy.created.first?.exercises.map(\.exercise.name) == ["Squat"])
    }

    @Test("Test Appearing Is Tracked As A Screen View")
    func testAppearingIsTrackedAsAScreenView() {
        let screen = makeScreen()

        screen.presenter.onViewAppear()
        screen.presenter.onViewDisappear()

        #expect(screen.interactor.trackedScreenEventNames == ["DefineWorkoutWrapperView_Appear"])
        #expect(screen.interactor.trackedEventNames == ["DefineWorkoutWrapperView_Disappear"])
    }
}

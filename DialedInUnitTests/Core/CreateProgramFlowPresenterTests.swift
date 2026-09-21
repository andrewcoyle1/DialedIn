//
//  CreateProgramFlowPresenterTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 21/09/2026.
//

// Nine presenters make up one wizard, and the value of these tests is in following a program
// from its name to its saved days in one place — so they live in one file, past the length limit.
// swiftlint:disable file_length

import Testing
import Foundation
import SwiftUI
@testable import DialedIn

/// A failure for the interactor doubles to throw, so the tests can drive the unhappy path.
private struct ProgramFlowTestError: Error { }

/// A flag a `@Sendable` completion closure can set.
///
/// Every step of this wizard copies the previous step's `onComplete` onto the delegate it builds,
/// and that closure is what returns the user to onboarding once the program is saved. Dropping it
/// cannot be seen by comparing delegates — the only way to know it survived is to call it.
private final class CompletionFlag: @unchecked Sendable {
    private(set) var fired = false

    func fire() {
        fired = true
    }
}

/// The first screen of creating a training program: an explainer with a Next button.
///
/// It holds nothing, so the only thing it can get wrong is losing the caller's completion handler
/// — the one that returns an onboarding user to where they left off once the program is saved.
@MainActor
struct ProgramFlowCreateProgramPresenterTests {

    private final class Interactor: SpyGlobalInteractor, CreateProgramInteractor { }

    private final class Router: CreateProgramRouter {
        let router: AnyRouter = TestRouting.anyRouter
        private(set) var nameDelegates: [NameProgramDelegate] = []

        func showNameProgramView(delegate: NameProgramDelegate) {
            nameDelegates.append(delegate)
        }
    }

    private struct Screen {
        let presenter: CreateProgramPresenter
        let interactor: Interactor
        let router: Router
    }

    private func makeScreen() -> Screen {
        let interactor = Interactor()
        let router = Router()
        return Screen(
            presenter: CreateProgramPresenter(interactor: interactor, router: router),
            interactor: interactor,
            router: router
        )
    }

    @Test("Test Next Opens The Naming Step")
    func testNextOpensTheNamingStep() {
        let screen = makeScreen()

        screen.presenter.onNextPressed(delegate: CreateProgramDelegate())

        #expect(screen.router.nameDelegates.count == 1)
    }

    /// When onboarding opens this flow it passes a completion handler, and onboarding cannot
    /// resume without it. It has to be copied onto every delegate from here to the last step.
    @Test("Test The Completion Handler Reaches The Naming Step")
    func testTheCompletionHandlerReachesTheNamingStep() {
        let screen = makeScreen()
        let flag = CompletionFlag()

        screen.presenter.onNextPressed(delegate: CreateProgramDelegate(onComplete: { flag.fire() }))
        screen.router.nameDelegates.first?.onComplete?()

        #expect(flag.fired)
    }

    /// Opened from the library rather than onboarding, there is no handler to carry, and the next
    /// step must be told that — it is what decides between resuming onboarding and just closing.
    @Test("Test No Completion Handler Is Carried When There Was None")
    func testNoCompletionHandlerIsCarriedWhenThereWasNone() {
        let screen = makeScreen()

        screen.presenter.onNextPressed(delegate: CreateProgramDelegate())

        #expect(screen.router.nameDelegates.first?.onComplete == nil)
    }

    @Test("Test Appearing Is Tracked As A Screen View")
    func testAppearingIsTrackedAsAScreenView() {
        let screen = makeScreen()

        screen.presenter.onViewAppear()

        #expect(screen.interactor.trackedScreenEventNames == ["CreateProgramView_Appear"])
    }
}

/// Naming the program.
///
/// The name typed here is the only thing this screen produces, and it has two more screens to
/// travel through before it reaches the saved program.
@MainActor
struct ProgramFlowNameProgramPresenterTests {

    private final class Interactor: SpyGlobalInteractor, NameProgramInteractor { }

    private final class Router: NameProgramRouter {
        private(set) var iconDelegates: [ProgramIconDelegate] = []

        func showProgramIconView(delegate: ProgramIconDelegate) {
            iconDelegates.append(delegate)
        }
    }

    private struct Screen {
        let presenter: NameProgramPresenter
        let interactor: Interactor
        let router: Router
    }

    private func makeScreen() -> Screen {
        let interactor = Interactor()
        let router = Router()
        return Screen(
            presenter: NameProgramPresenter(interactor: interactor, router: router),
            interactor: interactor,
            router: router
        )
    }

    /// Someone who has nothing in mind can press Next immediately, so the field starts on today's
    /// date rather than empty.
    @Test("Test The Name Starts As Todays Date")
    func testTheNameStartsAsTodaysDate() {
        let screen = makeScreen()

        #expect(screen.presenter.programName == Date.now.formattedDate)
        #expect(screen.presenter.canSave)
    }

    @Test("Test An Empty Name Cannot Be Saved")
    func testAnEmptyNameCannotBeSaved() {
        let screen = makeScreen()
        screen.presenter.programName = ""

        #expect(!screen.presenter.canSave)
    }

    @Test("Test The Typed Name Reaches The Icon Step")
    func testTheTypedNameReachesTheIconStep() {
        let screen = makeScreen()
        screen.presenter.programName = "Hypertrophy Block"

        screen.presenter.onNextPressed(delegate: NameProgramDelegate())

        #expect(screen.router.iconDelegates.first?.name == "Hypertrophy Block")
    }

    @Test("Test The Completion Handler Reaches The Icon Step")
    func testTheCompletionHandlerReachesTheIconStep() {
        let screen = makeScreen()
        let flag = CompletionFlag()

        screen.presenter.onNextPressed(delegate: NameProgramDelegate(onComplete: { flag.fire() }))
        screen.router.iconDelegates.first?.onComplete?()

        #expect(flag.fired)
    }

    @Test("Test Appearing Is Tracked As A Screen View")
    func testAppearingIsTrackedAsAScreenView() {
        let screen = makeScreen()

        screen.presenter.onViewAppear()

        #expect(screen.interactor.trackedScreenEventNames == ["NameProgramView_Appear"])
    }
}

/// Choosing the program's colour and icon.
///
/// This is the step that mints the program's identity: its id and its author. Everything the
/// previous two screens collected has to arrive at the design screen alongside it.
@MainActor
struct ProgramFlowProgramIconPresenterTests {

    private final class Interactor: SpyGlobalInteractor, ProgramIconInteractor {
        var userId: String?

        init(userId: String? = "user-1") {
            self.userId = userId
        }
    }

    private final class Router: ProgramIconRouter {
        private(set) var designDelegates: [ProgramDesignDelegate] = []

        func showProgramDesignView(delegate: ProgramDesignDelegate) {
            designDelegates.append(delegate)
        }
    }

    private struct Screen {
        let presenter: ProgramIconPresenter
        let interactor: Interactor
        let router: Router
    }

    private func makeScreen(userId: String? = "user-1") -> Screen {
        let interactor = Interactor(userId: userId)
        let router = Router()
        return Screen(
            presenter: ProgramIconPresenter(interactor: interactor, router: router),
            interactor: interactor,
            router: router
        )
    }

    @Test("Test A Colour And Icon Are Chosen To Begin With")
    func testAColourAndIconAreChosenToBeginWith() {
        let screen = makeScreen()

        #expect(screen.presenter.selectedColour == ProgramIconPresenter.defaultColours.first)
        #expect(screen.presenter.selectedIcon == ProgramIconPresenter.defaultIcons.first)
    }

    @Test("Test Pressing A Colour Selects It")
    func testPressingAColourSelectsIt() {
        let screen = makeScreen()

        screen.presenter.onColourPressed(colour: .green)

        #expect(screen.presenter.selectedColour == .green)
    }

    @Test("Test Pressing An Icon Selects It")
    func testPressingAnIconSelectsIt() {
        let screen = makeScreen()

        screen.presenter.onIconPressed(icon: "sailboat.fill")

        #expect(screen.presenter.selectedIcon == "sailboat.fill")
    }

    /// The name came from two screens back and is never shown here, which is exactly what makes it
    /// easy to drop when this step builds the design screen's delegate by hand.
    @Test("Test The Name Colour And Icon Reach The Design Step")
    func testTheNameColourAndIconReachTheDesignStep() {
        let screen = makeScreen()
        screen.presenter.onColourPressed(colour: .green)
        screen.presenter.onIconPressed(icon: "sailboat.fill")

        screen.presenter.onNextPressed(delegate: ProgramIconDelegate(name: "Hypertrophy Block"))

        let delegate = screen.router.designDelegates.first
        #expect(delegate?.name == "Hypertrophy Block")
        #expect(delegate?.colour == .green)
        #expect(delegate?.icon == "sailboat.fill")
    }

    /// The program is stamped with its author here, and the saved document is filed under that
    /// user — a program authored by the wrong person would not come back on the next sign-in.
    @Test("Test The Program Is Authored By The Signed In User")
    func testTheProgramIsAuthoredBySignedInUser() {
        let screen = makeScreen(userId: "user-7")

        screen.presenter.onNextPressed(delegate: ProgramIconDelegate(name: "Block"))

        #expect(screen.router.designDelegates.first?.authorId == "user-7")
    }

    /// Two programs created in a row must not share an id, or saving the second overwrites the
    /// first.
    @Test("Test Each Program Is Given Its Own Identifier")
    func testEachProgramIsGivenItsOwnIdentifier() {
        let screen = makeScreen()

        screen.presenter.onNextPressed(delegate: ProgramIconDelegate(name: "Block"))
        screen.presenter.onNextPressed(delegate: ProgramIconDelegate(name: "Block"))

        #expect(screen.router.designDelegates.count == 2)
        #expect(screen.router.designDelegates.first?.id.isEmpty == false)
        #expect(screen.router.designDelegates.first?.id != screen.router.designDelegates.last?.id)
    }

    /// Without a signed-in user there is nobody to author the program, so the step refuses to go
    /// on rather than creating one owned by nobody.
    @Test("Test A Signed Out User Cannot Reach The Design Step")
    func testASignedOutUserCannotReachTheDesignStep() {
        let screen = makeScreen(userId: nil)

        screen.presenter.onNextPressed(delegate: ProgramIconDelegate(name: "Block"))

        #expect(screen.router.designDelegates.isEmpty)
    }

    @Test("Test The Completion Handler Reaches The Design Step")
    func testTheCompletionHandlerReachesTheDesignStep() {
        let screen = makeScreen()
        let flag = CompletionFlag()

        screen.presenter.onNextPressed(delegate: ProgramIconDelegate(onComplete: { flag.fire() }, name: "Block"))
        screen.router.designDelegates.first?.onComplete?()

        #expect(flag.fired)
    }

    @Test("Test Appearing Is Tracked As A Screen View")
    func testAppearingIsTrackedAsAScreenView() {
        let screen = makeScreen()

        screen.presenter.onViewAppear()

        #expect(screen.interactor.trackedScreenEventNames == ["ProgramIconView_Appear"])
    }
}

/// Laying out the days of a program: adding, removing, renaming and ordering them.
///
/// This is where the program actually takes shape, and two things make it risky. The days are
/// auto-named ("Workout A", "Workout B", "Rest Day") from their contents, so a rest day in the
/// middle must not consume a letter and a name the user typed must never be overwritten. And the
/// settings sheet edits the same program through a `Binding` from behind this screen, so anything
/// this screen keeps a private copy of can silently diverge from what will be saved.
@MainActor
struct ProgramFlowProgramDesignPresenterTests {

    private final class Interactor: SpyGlobalInteractor, ProgramDesignInteractor {
        var userId: String? = "user-1"
        var currentUser: UserModel?
        var favouriteGymProfile: GymProfileModel?
        var activeTrainingProgram: TrainingProgram?
        var saveProgramError: Error?
        private(set) var savedPrograms: [TrainingProgram] = []
        private(set) var savedTemplates: [WorkoutTemplateModel] = []
        private(set) var activatedProgramIds: [String] = []

        func setActiveTrainingProgram(programId: String) async throws {
            activatedProgramIds.append(programId)
        }

        func saveTrainingProgram(trainingProgram: TrainingProgram) async throws {
            if let saveProgramError { throw saveProgramError }
            savedPrograms.append(trainingProgram)
        }

        func saveWorkoutTemplate(workoutTemplate: WorkoutTemplateModel, image: PlatformImage?) async throws {
            savedTemplates.append(workoutTemplate)
        }
    }

    /// The onboarding destinations come from `SpyOnboardingRouter`, since this screen can hand a
    /// user straight back into onboarding once the program is saved.
    private final class Router: SpyOnboardingRouter, ProgramDesignRouter {
        private(set) var renameDelegates: [RenameWorkoutTemplateModelDelegate] = []
        private(set) var settingsBindings: [Binding<TrainingProgram>] = []

        func showRenameWorkoutTemplateModelView(delegate: RenameWorkoutTemplateModelDelegate) {
            renameDelegates.append(delegate)
        }

        func showProgramSettingsView(program: Binding<TrainingProgram>) {
            settingsBindings.append(program)
            record("programSettings")
        }
    }

    private struct Screen {
        let presenter: ProgramDesignPresenter
        let interactor: Interactor
        let router: Router
    }

    private func program(days: [WorkoutTemplateModel] = []) -> TrainingProgram {
        TrainingProgram(
            id: "program-1",
            authorId: "user-1",
            name: "Block",
            icon: "flag",
            colour: "#FF0000",
            workoutTemplates: days
        )
    }

    private func day(_ name: String, exercises: Int = 0) -> WorkoutTemplateModel {
        WorkoutTemplateModel(
            id: UUID().uuidString,
            authorId: "user-1",
            name: name,
            exercises: (0..<exercises).map { _ in
                WorkoutTemplateExercise(exercise: ExerciseModel.mock, setRestTimers: false)
            }
        )
    }

    private func makeScreen(program: TrainingProgram? = nil) -> Screen {
        let interactor = Interactor()
        let router = Router()
        return Screen(
            presenter: ProgramDesignPresenter(
                interactor: interactor,
                router: router,
                program: program ?? self.program()
            ),
            interactor: interactor,
            router: router
        )
    }

    /// The `Binding` the view hands to the settings sheet, rebuilt here so a test can drive the
    /// settings round trip the way the toolbar button does.
    private func programBinding(_ presenter: ProgramDesignPresenter) -> Binding<TrainingProgram> {
        Binding(
            get: { MainActor.assumeIsolated { presenter.program } },
            set: { newValue in MainActor.assumeIsolated { presenter.program = newValue } }
        )
    }

    // MARK: - Starting state

    /// A brand new program arrives with no days at all, and a program with nothing in it cannot be
    /// laid out — so one rest day is created and selected to start from.
    @Test("Test A New Program Starts With One Selected Day")
    func testANewProgramStartsWithOneSelectedDay() {
        let screen = makeScreen()

        #expect(screen.presenter.dayPlans.count == 1)
        #expect(screen.presenter.selectedWorkoutTemplateModel.id == screen.presenter.dayPlans.first?.id)
        #expect(screen.presenter.program.workoutTemplates.count == 1)
    }

    @Test("Test An Existing Program Opens On Its First Day")
    func testAnExistingProgramOpensOnItsFirstDay() {
        let screen = makeScreen(program: program(days: [day("Push"), day("Pull")]))

        #expect(screen.presenter.dayPlans.map(\.name) == ["Push", "Pull"])
        #expect(screen.presenter.selectedWorkoutTemplateModel.name == "Push")
    }

    /// The program is what gets saved, so anything shown as a day has to be in it too.
    @Test("Test The Days Shown Are The Days That Will Be Saved")
    func testTheDaysShownAreTheDaysThatWillBeSaved() {
        let screen = makeScreen(program: program(days: [day("Push"), day("Pull")]))

        screen.presenter.onAddDayPressed()

        #expect(screen.presenter.program.workoutTemplates.map(\.id) == screen.presenter.dayPlans.map(\.id))
    }

    // MARK: - Adding and removing days

    @Test("Test Adding A Day Appends It And Selects It")
    func testAddingADayAppendsItAndSelectsIt() {
        let screen = makeScreen(program: program(days: [day("Push")]))

        screen.presenter.onAddDayPressed()

        #expect(screen.presenter.dayPlans.count == 2)
        #expect(screen.presenter.selectedWorkoutTemplateModel.id == screen.presenter.dayPlans.last?.id)
    }

    /// A program with no days cannot be trained, so the last one cannot be removed.
    @Test("Test The Last Day Cannot Be Removed")
    func testTheLastDayCannotBeRemoved() {
        let screen = makeScreen(program: program(days: [day("Push")]))

        #expect(!screen.presenter.canRemoveWorkoutTemplateModel)

        screen.presenter.onRemoveWorkoutTemplateModelPressed()

        #expect(screen.presenter.dayPlans.count == 1)
    }

    /// Removing the day being edited has to leave a different day selected, or the screen would be
    /// pointing at something that no longer exists.
    @Test("Test Removing The Selected Day Selects Another")
    func testRemovingTheSelectedDaySelectsAnother() {
        let screen = makeScreen(program: program(days: [day("Push"), day("Pull")]))
        screen.presenter.onWorkoutTemplateModelSelected(screen.presenter.dayPlans[1])

        screen.presenter.onRemoveWorkoutTemplateModelPressed()

        #expect(screen.presenter.dayPlans.map(\.name) == ["Push"])
        #expect(screen.presenter.selectedWorkoutTemplateModel.name == "Push")
    }

    // MARK: - Automatic day names

    /// Days are lettered in the order they are trained, and rest days are not workouts — a rest day
    /// between two sessions must not take "Workout B" and leave the second session as "Workout C".
    @Test("Test Rest Days Do Not Consume A Workout Letter")
    func testRestDaysDoNotConsumeAWorkoutLetter() {
        let screen = makeScreen(
            program: program(days: [day("Rest", exercises: 1), day("Rest"), day("Rest", exercises: 1)])
        )

        screen.presenter.onAddDayPressed()

        #expect(screen.presenter.dayPlans.map(\.name) == ["Workout A", "Rest Day", "Workout B", "Rest Day"])
    }

    /// Adding exercises to a rest day turns it into a workout, and the letters behind it have to
    /// shuffle up to match.
    @Test("Test Filling A Day Renames It And The Days After It")
    func testFillingADayRenamesItAndTheDaysAfterIt() {
        let screen = makeScreen(program: program(days: [day("Rest"), day("Rest", exercises: 1)]))
        screen.presenter.onWorkoutTemplateModelSelected(screen.presenter.dayPlans[0])

        screen.presenter.selectedWorkoutTemplateModelExercises.wrappedValue = [
            WorkoutTemplateExercise(exercise: ExerciseModel.mock, setRestTimers: false)
        ]

        #expect(screen.presenter.dayPlans.map(\.name) == ["Workout A", "Workout B"])
    }

    /// Exercises must land on the day that was selected, not on whichever day happens to be first.
    @Test("Test Exercises Are Written To The Selected Day")
    func testExercisesAreWrittenToTheSelectedDay() {
        let screen = makeScreen(program: program(days: [day("Push"), day("Pull")]))
        screen.presenter.onWorkoutTemplateModelSelected(screen.presenter.dayPlans[1])

        screen.presenter.selectedWorkoutTemplateModelExercises.wrappedValue = [
            WorkoutTemplateExercise(exercise: ExerciseModel.mock, setRestTimers: false)
        ]

        #expect(screen.presenter.dayPlans[0].exercises.isEmpty)
        #expect(screen.presenter.dayPlans[1].exercises.count == 1)
        #expect(screen.presenter.selectedWorkoutTemplateModel.exercises.count == 1)
    }

    /// A name the user typed is theirs. Only the generated names are re-generated.
    @Test("Test A Typed Day Name Survives Later Edits")
    func testATypedDayNameSurvivesLaterEdits() {
        let screen = makeScreen(program: program(days: [day("Rest", exercises: 1)]))

        screen.presenter.onRenameWorkoutTemplateModelPressed()
        screen.router.renameDelegates.first?.onSave("Leg Day")
        screen.presenter.onAddDayPressed()

        #expect(screen.presenter.dayPlans.map(\.name) == ["Leg Day", "Rest Day"])
    }

    /// The rename sheet is opened for the day being edited, and has to be handed that day's current
    /// name to start from.
    @Test("Test Renaming Starts From The Selected Days Name")
    func testRenamingStartsFromTheSelectedDaysName() {
        let screen = makeScreen(program: program(days: [day("Push"), day("Pull")]))
        screen.presenter.onWorkoutTemplateModelSelected(screen.presenter.dayPlans[1])

        screen.presenter.onRenameWorkoutTemplateModelPressed()

        #expect(screen.router.renameDelegates.first?.initialName == "Pull")
    }

    @Test("Test A Renamed Day Is Renamed In The Program")
    func testARenamedDayIsRenamedInTheProgram() {
        let screen = makeScreen(program: program(days: [day("Push")]))

        screen.presenter.onRenameWorkoutTemplateModelPressed()
        screen.router.renameDelegates.first?.onSave("Leg Day")

        #expect(screen.presenter.program.workoutTemplates.first?.name == "Leg Day")
        #expect(screen.presenter.selectedWorkoutTemplateModel.name == "Leg Day")
    }

    // MARK: - The settings sheet

    /// The settings sheet edits the program in place, through a binding onto this screen's program.
    @Test("Test Settings Are Given The Program To Edit")
    func testSettingsAreGivenTheProgramToEdit() {
        let screen = makeScreen()

        screen.presenter.onProgramSettingsPressed(program: programBinding(screen.presenter))

        #expect(screen.router.settingsBindings.first?.wrappedValue.id == "program-1")
    }

    /// Reordering the days in settings decides what is trained on which day. It used to be written
    /// into the program while this screen carried on showing — and then saving — its own stale copy
    /// of the old order, so the reorder was silently undone by the next edit.
    @Test("Test Reordering The Days In Settings Survives The Next Edit")
    func testReorderingTheDaysInSettingsSurvivesTheNextEdit() {
        let screen = makeScreen(program: program(days: [day("Push"), day("Pull"), day("Legs")]))
        let binding = programBinding(screen.presenter)

        screen.presenter.onProgramSettingsPressed(program: binding)
        let reordered = [screen.presenter.dayPlans[2], screen.presenter.dayPlans[0], screen.presenter.dayPlans[1]]
        screen.router.settingsBindings.first?.wrappedValue.workoutTemplates = reordered

        #expect(screen.presenter.dayPlans.map(\.name) == ["Legs", "Push", "Pull"])

        screen.presenter.onAddDayPressed()

        #expect(screen.presenter.dayPlans.map(\.name) == ["Legs", "Push", "Pull", "Rest Day"])
        #expect(screen.presenter.program.workoutTemplates.map(\.name) == ["Legs", "Push", "Pull", "Rest Day"])
    }

    /// The same divergence would lose the deload and cycle-count settings, which are what turn a
    /// week of days into a block of training.
    @Test("Test The Deload And Cycle Settings Survive The Next Edit")
    func testTheDeloadAndCycleSettingsSurviveTheNextEdit() {
        let screen = makeScreen(program: program(days: [day("Push")]))
        let binding = programBinding(screen.presenter)

        binding.wrappedValue.deload = .end
        binding.wrappedValue.numMicrocycles = 4
        screen.presenter.onAddDayPressed()

        #expect(screen.presenter.program.deload == .end)
        #expect(screen.presenter.program.numMicrocycles == 4)
    }

    // MARK: - Saving and activating

    @Test("Test Saving Stores The Program As It Stands")
    func testSavingStoresTheProgramAsItStands() async {
        let screen = makeScreen(program: program(days: [day("Push")]))
        screen.presenter.onAddDayPressed()

        screen.presenter.onSavePressed(delegate: ProgramDesignDelegate(
            id: "program-1", authorId: "user-1", name: "Block", colour: .red, icon: "flag"
        ))

        #expect(await TestManagers.eventually { screen.interactor.savedPrograms.count == 1 })
        #expect(screen.interactor.savedPrograms.first?.workoutTemplates.count == 2)
    }

    /// A save that fails must not look like it worked. The alert it raises goes through a
    /// `GlobalRouter` extension method, which is statically dispatched and so cannot be recorded by
    /// a double — what is checked here is that nothing was stored.
    @Test("Test A Failed Save Stores Nothing")
    func testAFailedSaveStoresNothing() async {
        let screen = makeScreen()
        screen.interactor.saveProgramError = ProgramFlowTestError()

        screen.presenter.onSavePressed(delegate: ProgramDesignDelegate(
            id: "program-1", authorId: "user-1", name: "Block", colour: .red, icon: "flag"
        ))

        _ = await TestManagers.eventually(timeout: .milliseconds(200)) { !screen.interactor.savedPrograms.isEmpty }
        #expect(screen.interactor.savedPrograms.isEmpty)
    }

    /// The screen shows an "active" badge, and it is keyed on the program being edited rather than
    /// on there merely being an active program.
    @Test("Test The Program Knows Whether It Is The Active One")
    func testTheProgramKnowsWhetherItIsTheActiveOne() {
        let screen = makeScreen()

        #expect(!screen.presenter.isProgramActive)

        screen.interactor.activeTrainingProgram = program()

        #expect(screen.presenter.isProgramActive)
    }

    /// Finishing a program during onboarding must return the user to onboarding, at the step their
    /// profile says they still owe — here, an account that has filled in nothing.
    @Test("Test Finishing During Onboarding Resumes Onboarding")
    func testFinishingDuringOnboardingResumesOnboarding() {
        let screen = makeScreen()
        screen.interactor.currentUser = UserModel(userId: "user-1")

        screen.presenter.handleNavigation()

        #expect(screen.router.shown == ["completeAccountSetup"])
    }

    /// Without a signed-in user there is no onboarding step to infer, so nothing is routed to
    /// rather than guessing at a destination.
    @Test("Test No Route Is Taken Without A Signed In User")
    func testNoRouteIsTakenWithoutASignedInUser() {
        let screen = makeScreen()

        screen.presenter.handleNavigation()

        #expect(screen.router.shown.isEmpty)
    }

    @Test("Test Appearing Is Tracked As A Screen View")
    func testAppearingIsTrackedAsAScreenView() {
        let screen = makeScreen()

        screen.presenter.onViewAppear()

        #expect(screen.interactor.trackedScreenEventNames == ["ProgramDesignView_Appear"])
    }
}

/// The program settings sheet: name, colour and icon, day order, deload and activation.
///
/// Every setting here is edited through a `Binding` onto the program being designed, so each row
/// is a pair — what it hands the editor to start from, and what it writes back when the editor
/// saves. A row that hands over the wrong value shows the user the wrong starting point; a row
/// that writes back to the wrong field loses their change.
@MainActor
struct ProgramFlowProgramSettingsPresenterTests {

    private final class Interactor: SpyGlobalInteractor, ProgramSettingsInteractor {
        var saveProgramError: Error?
        private(set) var savedPrograms: [TrainingProgram] = []
        private(set) var activatedProgramIds: [String] = []

        func saveTrainingProgram(trainingProgram: TrainingProgram) async throws {
            if let saveProgramError { throw saveProgramError }
            savedPrograms.append(trainingProgram)
        }

        func setActiveTrainingProgram(programId: String) async throws {
            activatedProgramIds.append(programId)
        }
    }

    private final class Router: ProgramSettingsRouter {
        let router: AnyRouter = TestRouting.anyRouter
        private(set) var renameDelegates: [RenameWorkoutTemplateModelDelegate] = []
        private(set) var colourIconStarts: [(colour: String, icon: String)] = []
        private(set) var colourIconSaves: [(String, String) -> Void] = []
        private(set) var dayOrderStarts: [[WorkoutTemplateModel]] = []
        private(set) var dayOrderSaves: [([WorkoutTemplateModel]) -> Void] = []
        private(set) var deloadStarts: [DeloadType] = []
        private(set) var deloadSaves: [(DeloadType) -> Void] = []

        func showRenameProgramView(delegate: RenameWorkoutTemplateModelDelegate) {
            renameDelegates.append(delegate)
        }

        func showEditProgramColourIconView(colour: String, icon: String, onSave: @escaping (String, String) -> Void) {
            colourIconStarts.append((colour, icon))
            colourIconSaves.append(onSave)
        }

        func showEditDayOrderView(dayPlans: [WorkoutTemplateModel], onSave: @escaping ([WorkoutTemplateModel]) -> Void) {
            dayOrderStarts.append(dayPlans)
            dayOrderSaves.append(onSave)
        }

        func showEditDeloadView(selected: DeloadType, onSave: @escaping (DeloadType) -> Void) {
            deloadStarts.append(selected)
            deloadSaves.append(onSave)
        }
    }

    /// Holds the program the sheet edits, and exposes the `Binding` the design screen passes in.
    /// `Binding`'s accessors are `@Sendable`, so the value has to live somewhere that can be
    /// reached from one — hence a box rather than a local, main-actor isolated so it is
    /// `Sendable`.
    @MainActor
    private final class MutableProgram {
        var value: TrainingProgram

        init(_ value: TrainingProgram) {
            self.value = value
        }

        var binding: Binding<TrainingProgram> {
            Binding(
                get: { MainActor.assumeIsolated { self.value } },
                set: { newValue in MainActor.assumeIsolated { self.value = newValue } }
            )
        }
    }

    private struct Screen {
        let presenter: ProgramSettingsPresenter
        let interactor: Interactor
        let router: Router
    }

    private func makeScreen() -> Screen {
        let interactor = Interactor()
        let router = Router()
        return Screen(
            presenter: ProgramSettingsPresenter(interactor: interactor, router: router),
            interactor: interactor,
            router: router
        )
    }

    private func day(_ name: String) -> WorkoutTemplateModel {
        WorkoutTemplateModel(id: name, authorId: "user-1", name: name)
    }

    private func box() -> MutableProgram {
        MutableProgram(
            TrainingProgram(
                id: "program-1",
                authorId: "user-1",
                name: "Block",
                icon: "flag",
                colour: "#FF0000",
                deload: .none,
                workoutTemplates: [day("Push"), day("Pull"), day("Legs")]
            )
        )
    }

    // MARK: - Name

    @Test("Test Renaming Starts From The Programs Current Name")
    func testRenamingStartsFromTheProgramsCurrentName() {
        let screen = makeScreen()
        let program = box()

        screen.presenter.onEditNamePressed(program: program.binding)

        #expect(screen.router.renameDelegates.first?.initialName == "Block")
    }

    @Test("Test A New Name Is Written Back To The Program")
    func testANewNameIsWrittenBackToTheProgram() {
        let screen = makeScreen()
        let program = box()

        screen.presenter.onEditNamePressed(program: program.binding)
        screen.router.renameDelegates.first?.onSave("Strength Block")

        #expect(program.value.name == "Strength Block")
    }

    // MARK: - Colour and icon

    @Test("Test The Colour Editor Starts From The Programs Colour And Icon")
    func testTheColourEditorStartsFromTheProgramsColourAndIcon() {
        let screen = makeScreen()
        let program = box()

        screen.presenter.onEditColourIconPressed(program: program.binding)

        #expect(screen.router.colourIconStarts.first?.colour == "#FF0000")
        #expect(screen.router.colourIconStarts.first?.icon == "flag")
    }

    /// Colour and icon are chosen on one screen and written back together — writing one and
    /// dropping the other leaves the program half-changed.
    @Test("Test A New Colour And Icon Are Both Written Back")
    func testANewColourAndIconAreBothWrittenBack() {
        let screen = makeScreen()
        let program = box()

        screen.presenter.onEditColourIconPressed(program: program.binding)
        screen.router.colourIconSaves.first?("#00FF00", "sailboat.fill")

        #expect(program.value.colour == "#00FF00")
        #expect(program.value.icon == "sailboat.fill")
    }

    // MARK: - Day order

    @Test("Test The Day Order Editor Starts From The Programs Days")
    func testTheDayOrderEditorStartsFromTheProgramsDays() {
        let screen = makeScreen()
        let program = box()

        screen.presenter.onEditDayOrderPressed(program: program.binding)

        #expect(screen.router.dayOrderStarts.first?.map(\.name) == ["Push", "Pull", "Legs"])
    }

    /// The order of the days is the order they are trained in, so this write is the whole point of
    /// the screen.
    @Test("Test A New Day Order Is Written Back To The Program")
    func testANewDayOrderIsWrittenBackToTheProgram() {
        let screen = makeScreen()
        let program = box()

        screen.presenter.onEditDayOrderPressed(program: program.binding)
        screen.router.dayOrderSaves.first?([day("Legs"), day("Push"), day("Pull")])

        #expect(program.value.workoutTemplates.map(\.name) == ["Legs", "Push", "Pull"])
    }

    // MARK: - Deload

    @Test("Test The Deload Editor Starts From The Programs Deload")
    func testTheDeloadEditorStartsFromTheProgramsDeload() {
        let screen = makeScreen()
        let program = box()
        program.value.deload = .start

        screen.presenter.onEditDeloadPressed(program: program.binding)

        #expect(screen.router.deloadStarts.first == .start)
    }

    @Test("Test A New Deload Is Written Back To The Program")
    func testANewDeloadIsWrittenBackToTheProgram() {
        let screen = makeScreen()
        let program = box()

        screen.presenter.onEditDeloadPressed(program: program.binding)
        screen.router.deloadSaves.first?(.end)

        #expect(program.value.deload == .end)
    }

    // MARK: - Activation

    /// Activating stores the program before pointing the user at it. The other order would leave
    /// the user following a program the backend has never been told about.
    @Test("Test Activating Saves The Program Before Making It Active")
    func testActivatingSavesTheProgramBeforeMakingItActive() async {
        let screen = makeScreen()
        let program = box()

        screen.presenter.onActivatePressed(program: program.value)

        #expect(await TestManagers.eventually { !screen.interactor.activatedProgramIds.isEmpty })
        #expect(screen.interactor.savedPrograms.map(\.id) == ["program-1"])
        #expect(screen.interactor.activatedProgramIds == ["program-1"])
    }

    /// If the program could not be stored, activating it would point the user at nothing.
    @Test("Test A Failed Save Does Not Activate The Program")
    func testAFailedSaveDoesNotActivateTheProgram() async {
        let screen = makeScreen()
        let program = box()
        screen.interactor.saveProgramError = ProgramFlowTestError()

        screen.presenter.onActivatePressed(program: program.value)

        _ = await TestManagers.eventually(timeout: .milliseconds(200)) { !screen.interactor.activatedProgramIds.isEmpty }
        #expect(screen.interactor.activatedProgramIds.isEmpty)
    }

    @Test("Test Appearing Is Tracked As A Screen View")
    func testAppearingIsTrackedAsAScreenView() {
        let screen = makeScreen()

        screen.presenter.onViewAppear()

        #expect(screen.interactor.trackedScreenEventNames == ["ProgramSettingsView_Appear"])
    }
}

/// The colour and icon editor reached from program settings.
///
/// It takes the program's colour as a hex string and hands one back, so the risk is the round
/// trip: a colour that does not survive being parsed and re-encoded changes every time the sheet
/// is opened and saved.
@MainActor
struct ProgramFlowColourIconEditorTests {

    private final class Router: EditProgramColourIconRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    /// Records what the sheet handed back, since the dismissal it also performs goes through a
    /// `GlobalRouter` extension method that a double cannot intercept.
    private final class SaveRecorder {
        private(set) var saves: [(colour: String, icon: String)] = []

        func record(_ colour: String, _ icon: String) {
            saves.append((colour, icon))
        }
    }

    private func makeScreen(
        colour: String = "#FF0000",
        icon: String = "flag"
    ) -> (EditProgramColourIconPresenter, SaveRecorder) {
        let recorder = SaveRecorder()
        let presenter = EditProgramColourIconPresenter(
            colour: colour,
            icon: icon,
            onSave: { recorder.record($0, $1) },
            router: Router()
        )
        return (presenter, recorder)
    }

    @Test("Test The Editor Opens On The Programs Colour And Icon")
    func testTheEditorOpensOnTheProgramsColourAndIcon() {
        let (presenter, _) = makeScreen(colour: "#00FF00", icon: "sailboat.fill")

        #expect(presenter.selectedColour.asHex() == "#00FF00")
        #expect(presenter.selectedIcon == "sailboat.fill")
    }

    /// Opening the sheet and saving without touching anything must give back exactly what it was
    /// given, or the program's colour drifts a little every time settings are opened.
    @Test("Test Saving Without Changing Anything Gives The Same Colour Back")
    func testSavingWithoutChangingAnythingGivesTheSameColourBack() {
        let (presenter, recorder) = makeScreen(colour: "#00FF00", icon: "sailboat.fill")

        presenter.onSavePressed()

        #expect(recorder.saves.first?.colour == "#00FF00")
        #expect(recorder.saves.first?.icon == "sailboat.fill")
    }

    @Test("Test A Chosen Colour And Icon Are Handed Back")
    func testAChosenColourAndIconAreHandedBack() {
        let (presenter, recorder) = makeScreen()

        presenter.onColourPressed(Color(hex: "#123456"))
        presenter.onIconPressed("gamecontroller")
        presenter.onSavePressed()

        #expect(recorder.saves.first?.colour == "#123456")
        #expect(recorder.saves.first?.icon == "gamecontroller")
    }

    @Test("Test Cancelling Changes Nothing")
    func testCancellingChangesNothing() {
        let (presenter, recorder) = makeScreen()

        presenter.onColourPressed(.green)
        presenter.onCancelPressed()

        #expect(recorder.saves.isEmpty)
    }

    @Test("Test The Editor Offers The Programs Palette")
    func testTheEditorOffersTheProgramsPalette() {
        let (presenter, _) = makeScreen()

        #expect(presenter.colours == ProgramIconPresenter.defaultColours)
        #expect(presenter.icons == ProgramIconPresenter.defaultIcons)
    }
}

/// The deload editor reached from program settings.
///
/// Deload decides whether a block starts or ends with a lighter cycle, so picking one and having
/// the other stored would change how the whole block is trained.
@MainActor
struct ProgramFlowEditDeloadPresenterTests {

    private final class Router: EditDeloadRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    /// The dismissal that accompanies a save goes through a `GlobalRouter` extension method, which
    /// a double cannot intercept — so only the handed-back value is recorded.
    private final class SaveRecorder {
        private(set) var saves: [DeloadType] = []

        func record(_ type: DeloadType) {
            saves.append(type)
        }
    }

    private func makeScreen(selected: DeloadType = .none) -> (EditDeloadPresenter, SaveRecorder) {
        let recorder = SaveRecorder()
        let presenter = EditDeloadPresenter(
            selected: selected,
            onSave: { recorder.record($0) },
            router: Router()
        )
        return (presenter, recorder)
    }

    @Test("Test Every Deload Option Is Offered")
    func testEveryDeloadOptionIsOffered() {
        let (presenter, _) = makeScreen()

        #expect(presenter.allCases == [.none, .start, .end])
    }

    @Test("Test The Editor Opens On The Programs Deload")
    func testTheEditorOpensOnTheProgramsDeload() {
        let (presenter, _) = makeScreen(selected: .end)

        #expect(presenter.selected == .end)
    }

    @Test("Test The Chosen Deload Is Handed Back")
    func testTheChosenDeloadIsHandedBack() {
        let (presenter, recorder) = makeScreen()

        presenter.onSelect(.start)
        presenter.onSavePressed()

        #expect(recorder.saves == [.start])
    }

    @Test("Test Cancelling Keeps The Programs Deload")
    func testCancellingKeepsTheProgramsDeload() {
        let (presenter, recorder) = makeScreen(selected: .none)

        presenter.onSelect(.end)
        presenter.onCancelPressed()

        #expect(recorder.saves.isEmpty)
    }
}

/// The day-order editor reached from program settings.
///
/// The order of the days is the order they are trained in, and the list hands its moves over in
/// SwiftUI's offset terms — where the destination is measured before the moved row is taken out.
/// Getting that wrong shifts every day by one.
@MainActor
struct ProgramFlowEditDayOrderPresenterTests {

    private final class Router: EditDayOrderRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    /// The dismissal that accompanies a save goes through a `GlobalRouter` extension method, which
    /// a double cannot intercept — so only the handed-back order is recorded.
    private final class SaveRecorder {
        private(set) var saves: [[WorkoutTemplateModel]] = []

        func record(_ plans: [WorkoutTemplateModel]) {
            saves.append(plans)
        }
    }

    private func day(_ name: String) -> WorkoutTemplateModel {
        WorkoutTemplateModel(id: name, authorId: "user-1", name: name)
    }

    private func makeScreen(_ names: [String] = ["Push", "Pull", "Legs"]) -> (EditDayOrderPresenter, SaveRecorder) {
        let recorder = SaveRecorder()
        let presenter = EditDayOrderPresenter(
            dayPlans: names.map { day($0) },
            onSave: { recorder.record($0) },
            router: Router()
        )
        return (presenter, recorder)
    }

    @Test("Test The Editor Opens On The Programs Day Order")
    func testTheEditorOpensOnTheProgramsDayOrder() {
        let (presenter, _) = makeScreen()

        #expect(presenter.dayPlans.map(\.name) == ["Push", "Pull", "Legs"])
    }

    /// Dragging the last day to the top: the destination is the index it lands on.
    @Test("Test Moving A Day Upwards Puts It At The Destination")
    func testMovingADayUpwardsPutsItAtTheDestination() {
        let (presenter, _) = makeScreen()

        presenter.move(fromOffsets: IndexSet(integer: 2), toOffset: 0)

        #expect(presenter.dayPlans.map(\.name) == ["Legs", "Push", "Pull"])
    }

    /// Dragging downwards, the destination is measured before the row is lifted out — so moving the
    /// first day "to 2" leaves it second, not third. This is the arithmetic an off-by-one would
    /// break.
    @Test("Test Moving A Day Downwards Counts The Destination Before The Move")
    func testMovingADayDownwardsCountsTheDestinationBeforeTheMove() {
        let (presenter, _) = makeScreen()

        presenter.move(fromOffsets: IndexSet(integer: 0), toOffset: 2)

        #expect(presenter.dayPlans.map(\.name) == ["Pull", "Push", "Legs"])
    }

    @Test("Test Moving A Day To The End Puts It Last")
    func testMovingADayToTheEndPutsItLast() {
        let (presenter, _) = makeScreen()

        presenter.move(fromOffsets: IndexSet(integer: 0), toOffset: 3)

        #expect(presenter.dayPlans.map(\.name) == ["Pull", "Legs", "Push"])
    }

    @Test("Test Saving Hands Back The New Order")
    func testSavingHandsBackTheNewOrder() {
        let (presenter, recorder) = makeScreen()

        presenter.move(fromOffsets: IndexSet(integer: 2), toOffset: 0)
        presenter.onSavePressed()

        #expect(recorder.saves.first?.map(\.name) == ["Legs", "Push", "Pull"])
    }

    /// Reordering is destructive to a training week, so backing out must leave the program alone.
    @Test("Test Cancelling Keeps The Programs Day Order")
    func testCancellingKeepsTheProgramsDayOrder() {
        let (presenter, recorder) = makeScreen()

        presenter.move(fromOffsets: IndexSet(integer: 2), toOffset: 0)
        presenter.onCancelPressed()

        #expect(recorder.saves.isEmpty)
    }
}

/// The sheet for renaming a day of the program.
///
/// A day's name is what the dashboard matches logged sessions against, so a name that is blank or
/// padded with spaces is worse than no rename at all.
@MainActor
struct ProgramFlowRenameDayPlanPresenterTests {

    private final class Interactor: RenameWorkoutTemplateModelInteractor { }

    private final class Router: RenameWorkoutTemplateModelRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    /// The dismissal that accompanies a save goes through a `GlobalRouter` extension method, which
    /// a double cannot intercept — so only the handed-back name is recorded.
    private final class SaveRecorder {
        private(set) var saves: [String] = []

        func record(_ name: String) {
            saves.append(name)
        }
    }

    private func makeScreen(initialName: String = "Push") -> RenameWorkoutTemplateModelPresenter {
        RenameWorkoutTemplateModelPresenter(
            interactor: Interactor(),
            router: Router(),
            initialName: initialName
        )
    }

    @Test("Test The Sheet Opens On The Days Current Name")
    func testTheSheetOpensOnTheDaysCurrentName() {
        let presenter = makeScreen()

        #expect(presenter.nameText == "Push")
        #expect(presenter.canSave)
    }

    @Test("Test A Blank Name Cannot Be Saved")
    func testABlankNameCannotBeSaved() {
        let presenter = makeScreen()
        presenter.nameText = "   "

        #expect(!presenter.canSave)
    }

    /// Pressing save with only spaces typed must not rename the day to nothing, even if the button
    /// were somehow reachable.
    @Test("Test Saving A Blank Name Renames Nothing")
    func testSavingABlankNameRenamesNothing() {
        let presenter = makeScreen()
        let recorder = SaveRecorder()
        presenter.nameText = "  "

        presenter.onSavePressed(onSave: { recorder.record($0) })

        #expect(recorder.saves.isEmpty)
    }

    /// Stray spaces around a typed name would make the day fail to match the sessions logged
    /// against it, so the name is trimmed on the way out.
    @Test("Test A Typed Name Is Trimmed On The Way Out")
    func testATypedNameIsTrimmedOnTheWayOut() {
        let presenter = makeScreen()
        let recorder = SaveRecorder()
        presenter.nameText = "  Leg Day  "

        presenter.onSavePressed(onSave: { recorder.record($0) })

        #expect(recorder.saves == ["Leg Day"])
    }
}

// swiftlint:enable file_length

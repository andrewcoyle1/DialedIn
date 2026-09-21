//
//  PrevWORefSettingsPresenterTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 21/09/2026.
//

import Testing
import Foundation
import SwiftUI
@testable import DialedIn

/// The one-question screen behind "Previous Reference": whether the greyed-out numbers beside each
/// set during a workout come from any workout that included the exercise, or only from workouts in
/// the same program.
///
/// The question itself is a two-case enum and hard to get wrong. What is easy to get wrong is the
/// saving: every one of these settings screens edits a snapshot of the whole `WorkoutSettings`
/// document and writes the whole thing back, so a snapshot taken when the screen was built and
/// never refreshed silently reverts anything changed elsewhere in between. The sibling screens each
/// re-read on appear for exactly that reason; the test below pins that this one does too.
@MainActor
struct PrevWORefSettingsPresenterTests {

    private final class Interactor: SpyGlobalInteractor, PrevWORefSettingsInteractor {
        var workoutSettings = WorkoutSettings(authorId: "user-1")
        private(set) var saved: [WorkoutSettings] = []

        func saveWorkoutSettings(_ workoutSettings: WorkoutSettings) async throws {
            saved.append(workoutSettings)
            self.workoutSettings = workoutSettings
        }
    }

    private final class Router: PreviousWorkoutReferenceSettingsRouter {
        let router: AnyRouter = TestRouting.anyRouter

        func showAlert(error: Error) { }
        func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) { }
        func showSimpleAlert(title: String, subtitle: String?) { }
    }

    private struct Screen {
        let presenter: PrevWORefSettingsPresenter
        let interactor: Interactor
        let delegate = PrevWORefSettingsDelegate()
    }

    private func makeScreen(settings: WorkoutSettings = WorkoutSettings(authorId: "user-1")) -> Screen {
        let interactor = Interactor()
        interactor.workoutSettings = settings
        return Screen(
            presenter: PrevWORefSettingsPresenter(interactor: interactor, router: Router()),
            interactor: interactor
        )
    }

    // MARK: - The choice

    /// Both options are offered, in the order the enum declares them, so the list does not reshuffle
    /// between launches.
    @Test("Test Both Reference Options Are Offered")
    func testBothReferenceOptionsAreOffered() {
        let screen = makeScreen()

        #expect(screen.presenter.options == [.anyWorkout, .workoutsInProgram])
    }

    /// The screen shows what is actually saved, so the tick is beside the option in force rather
    /// than beside the default.
    @Test("Test The Saved Option Is The One Shown")
    func testTheSavedOptionIsTheOneShown() {
        var settings = WorkoutSettings(authorId: "user-1")
        settings.previousWorkoutReference = .workoutsInProgram
        let screen = makeScreen(settings: settings)

        #expect(screen.presenter.previousWorkoutReference == .workoutsInProgram)
    }

    /// Choosing an option saves it immediately — there is no Done button on this screen, so an
    /// unsaved choice would simply be lost on the way back.
    @Test("Test Choosing An Option Saves It Immediately")
    func testChoosingAnOptionSavesItImmediately() async {
        let screen = makeScreen()

        screen.presenter.previousWorkoutReference = .workoutsInProgram

        #expect(screen.presenter.previousWorkoutReference == .workoutsInProgram)
        #expect(await TestManagers.eventually {
            screen.interactor.saved.last?.previousWorkoutReference == .workoutsInProgram
        })
    }

    // MARK: - Not clobbering the rest of the document

    /// A save from this screen writes the whole settings document, so it has to be writing back the
    /// current one. Changing the rest timer, coming here and picking an option must not quietly put
    /// the rest timer back — the user would find a setting they deliberately changed undone by a
    /// screen that has nothing to do with it.
    @Test("Test Choosing An Option Does Not Revert Other Settings")
    func testChoosingAnOptionDoesNotRevertOtherSettings() async {
        let screen = makeScreen()

        // Another screen saves a different setting after this presenter was built.
        var changedElsewhere = screen.interactor.workoutSettings
        changedElsewhere.defaultRestDurationSeconds = 150
        changedElsewhere.rirTracking = true
        screen.interactor.workoutSettings = changedElsewhere

        screen.presenter.onViewAppear(delegate: screen.delegate)
        screen.presenter.previousWorkoutReference = .workoutsInProgram

        #expect(await TestManagers.eventually {
            screen.interactor.saved.last?.previousWorkoutReference == .workoutsInProgram
        })
        #expect(screen.interactor.saved.last?.defaultRestDurationSeconds == 150)
        #expect(screen.interactor.saved.last?.rirTracking == true)
    }

    /// And the choice itself survives the re-read: appearing again after a save must not reset the
    /// screen to whatever it was built with.
    @Test("Test A Saved Choice Survives The Screen Reappearing")
    func testASavedChoiceSurvivesTheScreenReappearing() async {
        let screen = makeScreen()
        screen.presenter.previousWorkoutReference = .workoutsInProgram
        #expect(await TestManagers.eventually { screen.interactor.saved.count == 1 })

        screen.presenter.onViewAppear(delegate: screen.delegate)

        #expect(screen.presenter.previousWorkoutReference == .workoutsInProgram)
    }

    // MARK: - Lifecycle

    @Test("Test The Reference Screen Tracks Its Own Lifecycle")
    func testTheReferenceScreenTracksItsOwnLifecycle() {
        let screen = makeScreen()

        screen.presenter.onViewAppear(delegate: screen.delegate)
        screen.presenter.onViewDisappear(delegate: screen.delegate)

        #expect(screen.interactor.trackedScreenEventNames == ["PreviousWorkoutReferenceSettingsView_Appear"])
        #expect(screen.interactor.trackedEventNames == ["PreviousWorkoutReferenceSettingsView_Disappear"])
    }
}

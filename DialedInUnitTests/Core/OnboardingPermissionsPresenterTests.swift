//
//  OnboardingPermissionsPresenterTests.swift
//  DialedInUnitTests
//

import Testing
import Foundation
import SwiftUI
@testable import DialedIn

// The three screens between the profile being saved and goal setting: the notifications ask, the
// HealthKit ask, and the health disclaimer.
//
// The first two are optional and the third is not. What matters on all three is that every answer
// — including "no" and including a failure — leaves the user with a way forward. A branch that
// goes nowhere strands them one screen short of the app with no back button.
//
// The router doubles subclass `SpyOnboardingRouter` so the alert methods stay intercepted on the
// class that declares the `GlobalRouter` conformance; see its comment for why re-declaring them in
// a subclass would silently let the alert escape.

// MARK: - Step 10: notifications

@MainActor
struct NotificationsPermissionsPresenterTests {

    private final class Interactor: SpyGlobalInteractor, NotificationsPermissionsInteractor {
        var isAuthorised = true
        var shouldThrow = false
        var canRequestHealthData = false
        private(set) var requestCount = 0

        func requestPushAuthorisation() async throws -> Bool {
            requestCount += 1
            if shouldThrow { throw URLError(.cancelled) }
            return isAuthorised
        }

        func canRequestHealthDataAuthorisation() -> Bool { canRequestHealthData }
    }

    /// The modal's confirm and cancel closures are captured so a test can press its buttons; the
    /// modal itself is a `showModal` on the real router and never renders here.
    private final class Router: SpyOnboardingRouter, NotificationsPermissionsRouter {
        var onConfirm: (() -> Void)?
        var onCancel: (() -> Void)?

        func showNotificationsPermissionsModal(
            onConfirmPressed: @escaping () -> Void,
            onCancelPressed: @escaping () -> Void
        ) {
            record("permissionsModal")
            onConfirm = onConfirmPressed
            onCancel = onCancelPressed
        }

        func showDevSettingsView() { record("devSettings") }
    }

    private struct Screen {
        let sut: NotificationsPermissionsPresenter
        let interactor: Interactor
        let router: Router
    }

    private func makeScreen(_ configure: (Interactor) -> Void = { _ in }) -> Screen {
        let interactor = Interactor()
        configure(interactor)
        let router = Router()
        return Screen(
            sut: NotificationsPermissionsPresenter(interactor: interactor, router: router),
            interactor: interactor,
            router: router
        )
    }

    @Test("Our own modal is shown before the system prompt is spent")
    func testEnablingAsksOurOwnModalBeforeTheSystemOne() {
        let screen = makeScreen()
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router

        sut.onEnableNotificationsPressed()

        // iOS shows its prompt once per install. Asking first means it is only spent on someone
        // who has already said yes.
        #expect(router.shown == ["permissionsModal"])
        #expect(interactor.requestCount == 0)
    }

    @Test("Cancelling our modal never asks the system")
    func testCancellingTheModalNeverAsksTheSystem() {
        let screen = makeScreen()
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router
        sut.onEnableNotificationsPressed()

        router.onCancel?()

        #expect(interactor.requestCount == 0)
        #expect(router.shown == ["permissionsModal"])
        #expect(interactor.trackedEventNames.contains("OnboardingNotificiationsView_PushNotifsModal_Dismiss"))
    }

    @Test("Declining the system prompt still moves onboarding on")
    func testDecliningTheSystemPromptStillMovesOnboardingOn() async {
        let screen = makeScreen { $0.isAuthorised = false }
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router
        sut.onEnableNotificationsPressed()

        router.onConfirm?()
        await TestManagers.eventually { router.shown.contains("healthDisclaimer") }

        // Declining is a perfectly ordinary answer, not an error state.
        #expect(interactor.requestCount == 1)
        #expect(router.shown == ["permissionsModal", "healthDisclaimer"])
        #expect(router.alertTitles.isEmpty)
    }

    @Test("Health data comes next when it can still be asked for")
    func testHealthDataFollowsNotificationsWhenItCanBeAskedFor() async {
        let screen = makeScreen { $0.canRequestHealthData = true }
        let sut = screen.sut
        let router = screen.router
        sut.onEnableNotificationsPressed()

        router.onConfirm?()
        await TestManagers.eventually { router.shown.contains("healthData") }

        #expect(router.shown == ["permissionsModal", "healthData"])
    }

    @Test("Granting is recorded with the answer the system gave")
    func testGrantingIsRecordedWithTheAnswer() async {
        let screen = makeScreen()
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router
        sut.onEnableNotificationsPressed()

        router.onConfirm?()
        await TestManagers.eventually { router.shown.contains("healthDisclaimer") }

        #expect(interactor.trackedEventNames.contains("OnboardingNotificiationsView_EnableNotifications_Success"))
    }

    @Test("A request that throws is logged and leaves the user on the screen")
    func testAFailedRequestIsLoggedAndDoesNotNavigate() async {
        let screen = makeScreen { $0.shouldThrow = true }
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router
        sut.onEnableNotificationsPressed()

        router.onConfirm?()
        await TestManagers.eventually {
            interactor.trackedEventNames.contains("OnboardingNotificiationsView_EnableNotifications_Fail")
        }

        #expect(router.shown == ["permissionsModal"])
    }

    @Test("Skip for now still works after a failed request, so the screen is never a dead end")
    func testSkipStillWorksAfterAFailedRequest() async {
        let screen = makeScreen { $0.shouldThrow = true }
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router
        sut.onEnableNotificationsPressed()
        router.onConfirm?()
        await TestManagers.eventually {
            interactor.trackedEventNames.contains("OnboardingNotificiationsView_EnableNotifications_Fail")
        }

        sut.onSkipForNowPressed()
        await TestManagers.eventually { router.shown.contains("healthDisclaimer") }

        #expect(router.shown == ["permissionsModal", "healthDisclaimer"])
    }

    @Test("Skipping goes exactly where accepting would have")
    func testSkippingGoesWhereAcceptingWouldHave() async {
        let screen = makeScreen { $0.canRequestHealthData = true }
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router

        sut.onSkipForNowPressed()
        await TestManagers.eventually { !router.shown.isEmpty }

        #expect(router.shown == ["healthData"])
        #expect(interactor.requestCount == 0)
        #expect(interactor.trackedEventNames.contains("OnboardingNotificiationsView_Notifications_SkipForNow"))
    }
}

// MARK: - Step 11: health data

/// The HealthKit ask. HealthKit never reports a denial back to the app — the request simply
/// succeeds — so the only failure the screen can see is one where the sheet could not be shown at
/// all. Both outcomes have to leave a route to the disclaimer.
@MainActor
struct OnboardingHealthDataPresenterTests {

    private final class Interactor: SpyGlobalInteractor, OnboardingHealthDataInteractor {
        var shouldThrow = false
        private(set) var requestCount = 0

        func canRequestHealthDataAuthorisation() async -> Bool { true }

        func requestHealthKitAuthorisation() async throws {
            requestCount += 1
            if shouldThrow { throw URLError(.cancelled) }
        }
    }

    private final class Router: SpyOnboardingRouter, OnboardingHealthDataRouter {
        func showDevSettingsView() { record("devSettings") }
    }

    private struct Screen {
        let sut: OnboardingHealthDataPresenter
        let interactor: Interactor
        let router: Router
    }

    private func makeScreen(_ configure: (Interactor) -> Void = { _ in }) -> Screen {
        let interactor = Interactor()
        configure(interactor)
        let router = Router()
        return Screen(
            sut: OnboardingHealthDataPresenter(interactor: interactor, router: router),
            interactor: interactor,
            router: router
        )
    }

    @Test("Allowing health access moves on to the disclaimer")
    func testGrantingHealthAccessMovesOnToTheDisclaimer() async {
        let screen = makeScreen()
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router

        sut.onAllowAccessPressed()
        await TestManagers.eventually { !router.shown.isEmpty }

        #expect(interactor.requestCount == 1)
        #expect(router.shown == ["healthDisclaimer"])
        #expect(interactor.trackedEventNames.contains("Onboarding_EnableHealthKit_Success"))
    }

    @Test("Denying inside the HealthKit sheet is indistinguishable from allowing, and still moves on")
    func testDenyingInsideTheSheetStillMovesOn() async {
        // `requestAuthorization` returns without error whether the user ticked the boxes or not,
        // which is exactly what the non-throwing double models here. The screen must not try to
        // gate on an answer it was never given.
        let screen = makeScreen()
        let sut = screen.sut
        let router = screen.router

        sut.onAllowAccessPressed()
        await TestManagers.eventually { !router.shown.isEmpty }

        #expect(router.shown == ["healthDisclaimer"])
        #expect(router.alertedErrors.isEmpty)
    }

    @Test("A health access failure is surfaced rather than swallowed")
    func testAHealthAccessFailureIsSurfaced() async {
        let screen = makeScreen { $0.shouldThrow = true }
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router

        sut.onAllowAccessPressed()
        await TestManagers.eventually { !router.alertedErrors.isEmpty }

        #expect(router.alertedErrors.count == 1)
        #expect(router.shown.isEmpty)
        #expect(interactor.trackedEventNames.contains("Onboarding_EnableHealthKit_Fail"))
    }

    @Test("Skip for now still works after a failure, so the screen is never a dead end")
    func testSkipStillWorksAfterAFailure() async {
        let screen = makeScreen { $0.shouldThrow = true }
        let sut = screen.sut
        let router = screen.router
        sut.onAllowAccessPressed()
        await TestManagers.eventually { !router.alertedErrors.isEmpty }

        sut.onSkipForNowPressed()

        #expect(router.shown == ["healthDisclaimer"])
    }

    @Test("Skipping health access reaches the same screen as allowing it")
    func testSkippingHealthAccessStillReachesTheDisclaimer() {
        let screen = makeScreen()
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router

        sut.onSkipForNowPressed()

        #expect(router.shown == ["healthDisclaimer"])
        #expect(interactor.requestCount == 0)
    }
}

// MARK: - Step 5 of onboarding proper: the health disclaimer

/// What the screen asked the user manager to store.
private struct RecordedConsent {
    let disclaimer: String
    let privacy: String
    let acceptedAt: Date
}

/// The one consent screen in onboarding. What it records is the pair of version strings and the
/// moment of acceptance; `UserModel.inferredOnboardingStep` reads them back to decide whether the
/// user still owes an acceptance.
@MainActor
struct HealthDisclaimerPresenterTests {

    private final class Interactor: SpyGlobalInteractor, HealthDisclaimerInteractor {
        var shouldThrow = false
        private(set) var consents: [RecordedConsent] = []

        func updateHealthConsents(disclaimerVersion: String, privacyVersion: String, acceptedAt: Date) async throws {
            if shouldThrow { throw URLError(.notConnectedToInternet) }
            consents.append(RecordedConsent(disclaimer: disclaimerVersion, privacy: privacyVersion, acceptedAt: acceptedAt))
        }
    }

    private final class Router: SpyOnboardingRouter, HealthDisclaimerRouter {
        var onConfirm: (() -> Void)?
        var onCancel: (() -> Void)?

        func showHealthDisclaimerConfirmationModal(
            onConfirmPressed: @escaping () -> Void,
            onCancelPressed: @escaping () -> Void
        ) {
            record("confirmationModal")
            onConfirm = onConfirmPressed
            onCancel = onCancelPressed
        }

        func showDevSettingsView() { record("devSettings") }
    }

    private struct Screen {
        let sut: HealthDisclaimerPresenter
        let interactor: Interactor
        let router: Router
    }

    private func makeScreen() -> Screen {
        let interactor = Interactor()
        let router = Router()
        return Screen(
            sut: HealthDisclaimerPresenter(interactor: interactor, router: router),
            interactor: interactor,
            router: router
        )
    }

    /// Accepting one of the two notices is not accepting both, and the consent record would claim
    /// otherwise.
    @Test("Both acknowledgements are needed before Continue does anything")
    func testBothAcknowledgementsAreNeeded() {
        let screen = makeScreen()
        let sut = screen.sut
        let router = screen.router

        #expect(sut.canContinue == false)
        sut.onContinuePressed()
        #expect(router.shown.isEmpty)

        sut.acceptedTerms = true
        #expect(sut.canContinue == false)
        sut.onContinuePressed()
        #expect(router.shown.isEmpty)

        sut.acceptedPrivacy = true
        #expect(sut.canContinue)
        sut.onContinuePressed()
        #expect(router.shown == ["confirmationModal"])
    }

    @Test("Continue only opens the confirmation; nothing is recorded until it is confirmed")
    func testContinueRecordsNothingOnItsOwn() {
        let screen = makeScreen()
        let sut = screen.sut
        let interactor = screen.interactor
        sut.acceptedTerms = true
        sut.acceptedPrivacy = true

        sut.onContinuePressed()

        #expect(interactor.consents.isEmpty)
    }

    @Test("Backing out of the confirmation records no consent and goes nowhere")
    func testCancellingTheConfirmationRecordsNothing() async {
        let screen = makeScreen()
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router
        sut.acceptedTerms = true
        sut.acceptedPrivacy = true
        sut.onContinuePressed()

        router.onCancel?()

        #expect(interactor.consents.isEmpty)
        #expect(router.shown == ["confirmationModal"])
    }

    @Test("Confirming records the versions the screen presented and moves on to goal setting")
    func testConfirmingRecordsTheConsentAndMovesOn() async {
        let screen = makeScreen()
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router
        sut.acceptedTerms = true
        sut.acceptedPrivacy = true
        sut.onContinuePressed()

        router.onConfirm?()
        await TestManagers.eventually { !interactor.consents.isEmpty }

        #expect(interactor.consents.first?.disclaimer == UserModel.currentHealthDisclaimerVersion)
        #expect(interactor.consents.first?.privacy == UserModel.currentHealthPrivacyPolicyVersion)
        #expect(router.shown == ["confirmationModal", "goalSetting"])
        #expect(interactor.trackedEventNames.contains("consent_health_confirm_success"))
    }

    @Test("The acceptance is dated to when the user confirmed, not to when the write landed")
    func testTheAcceptanceIsDatedToTheConfirmation() async {
        let screen = makeScreen()
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router
        sut.acceptedTerms = true
        sut.acceptedPrivacy = true
        sut.onContinuePressed()

        let before = Date()
        router.onConfirm?()
        await TestManagers.eventually { !interactor.consents.isEmpty }
        let after = Date()

        let acceptedAt = interactor.consents.first?.acceptedAt ?? .distantPast
        #expect(acceptedAt >= before && acceptedAt <= after)
    }

    @Test("A failed write is reported, records nothing, and leaves goal setting unreached")
    func testAFailedWriteIsReportedAndGoesNowhere() async {
        let screen = makeScreen()
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router
        interactor.shouldThrow = true
        sut.acceptedTerms = true
        sut.acceptedPrivacy = true
        sut.onContinuePressed()

        router.onConfirm?()
        await TestManagers.eventually { !router.alertTitles.isEmpty }

        #expect(router.alertTitles == ["Unable to save"])
        #expect(router.shown == ["confirmationModal"])
        #expect(interactor.trackedEventNames.contains("consent_health_confirm_fail"))
    }

    @Test("The user can confirm again after a failed write")
    func testTheUserCanRetryAfterAFailedWrite() async {
        let screen = makeScreen()
        let sut = screen.sut
        let interactor = screen.interactor
        let router = screen.router
        interactor.shouldThrow = true
        sut.acceptedTerms = true
        sut.acceptedPrivacy = true
        sut.onContinuePressed()
        router.onConfirm?()
        await TestManagers.eventually { !router.alertTitles.isEmpty }

        interactor.shouldThrow = false
        // The toggles are untouched by the failure, so Continue is still live.
        #expect(sut.canContinue)
        sut.onContinuePressed()
        router.onConfirm?()
        await TestManagers.eventually { !interactor.consents.isEmpty }

        #expect(interactor.consents.count == 1)
        #expect(router.shown.contains("goalSetting"))
    }

    /// A user whose profile is complete, so the only thing that can send them back to the
    /// disclaimer is the consent they hold.
    private func userAccepting(_ version: String?) -> UserModel {
        UserModel(
            userId: "consent-user",
            submittedDateOfBirth: Calendar.current.date(from: DateComponents(year: 1990, month: 1, day: 1)),
            submittedGender: .male,
            submittedHeightCentimeters: 180,
            submittedWeightKilograms: 80,
            submittedExerciseFrequency: .threeToFour,
            submittedDailyActivityLevel: .moderate,
            submittedCardioFitnessLevel: .intermediate,
            submittedCurrentGoalId: "goal-1",
            acceptedHealthDisclaimerVersion: version
        )
    }

    @Test("A user who has never accepted is sent to the disclaimer")
    func testANeverAcceptedUserIsSentToTheDisclaimer() {
        #expect(userAccepting(nil).inferredOnboardingStep == .healthDisclaimer)
    }

    @Test("Accepting the current version clears the disclaimer step")
    func testAcceptingTheCurrentVersionClearsTheStep() {
        #expect(userAccepting(UserModel.currentHealthDisclaimerVersion).inferredOnboardingStep != .healthDisclaimer)
    }
}

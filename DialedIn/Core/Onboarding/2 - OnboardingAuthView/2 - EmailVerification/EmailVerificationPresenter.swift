//
//  EmailVerificationPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI

@Observable
@MainActor
class EmailVerificationPresenter {
    private let interactor: EmailVerificationInteractor
    private let router: EmailVerificationRouter

    var isLoadingCheck: Bool = false
    var isLoadingResend: Bool = false

    var currentAuthTask: Task<Void, Never>?
    var currentPollingTask: Task<Void, Never>?

    private(set) var toastMessage: String?
    private let pollIntervalSeconds: Double = 7

    init(
        interactor: EmailVerificationInteractor,
        router: EmailVerificationRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func setup() {
        startSendVerificationEmail(isInitial: true)
        startPolling()
    }

    // MARK: Send Verification Email
    func startSendVerificationEmail(isInitial: Bool = false, onDismiss: @escaping @Sendable () -> Void = {}) {
        // If user is not signed in, show recovery alert
        guard interactor.auth != nil else {
            showNotSignedInAlert(onDismiss: onDismiss)
            return
        }
        // Prevent overlapping operations
        currentAuthTask?.cancel()

        currentAuthTask = Task {
            isLoadingResend = true
            defer {
                isLoadingResend = false
                currentAuthTask = nil
            }

            interactor.trackEvent(event: Event.sendEmailVerificationStart)
            do {
                try await performAuthWithTimeout {
                    try await self.interactor.sendVerificationEmail()
                }
                interactor.trackEvent(event: Event.sendEmailVerificationSuccess)
                let message = isInitial ? "Verification email sent" : "Verification email resent"
                showToast(message)
            } catch {
                if !Task.isCancelled {
                    interactor.trackEvent(event: Event.sendEmailVerificationFail(error: error))
                    let errorInfo = interactor.handleAuthError(error, operation: "send verification email")
                    router.showAlert(
                        title: errorInfo.title,
                        subtitle: errorInfo.message,
                        buttons: {
                            AnyView(
                                HStack {
                                    Button("Cancel") { }
                                    if errorInfo.isRetryable {
                                        Button("Try Again") {
                                            self.startSendVerificationEmail(isInitial: isInitial)
                                        }
                                    }
                                }
                            )
                        }
                    )
                }
            }
        }
    }

    // MARK: On Done Pressed
    func onDonePressed(onDismiss: @escaping @Sendable () -> Void = {}) {
        // If user is not signed in, show recovery alert
        guard interactor.auth != nil else {
            self.showNotSignedInAlert(onDismiss: onDismiss)
            return
        }
        // Prevent overlapping operations
        currentAuthTask?.cancel()

        currentAuthTask = Task {
            isLoadingCheck = true
            defer {
                isLoadingCheck = false
                currentAuthTask = nil
            }

            interactor.trackEvent(event: Event.checkEmailVerificationStart)
            do {
                let isVerified: Bool = try await performAuthWithTimeout {
                    return try await self.interactor.checkVerificationEmail()
                }
                interactor.trackEvent(event: Event.checkEmailVerificationSuccess(isVerified: isVerified))
                handleDidCheckEmailVerification(isVerified: isVerified, onDismiss: onDismiss)
            } catch {
                if !Task.isCancelled {
                    interactor.trackEvent(event: Event.checkEmailVerificationFail(error: error))
                    let errorInfo = interactor.handleAuthError(error, operation: "check email verification")
                    router.showAlert(
                        title: errorInfo.title,
                        subtitle: errorInfo.message,
                        buttons: {
                            AnyView(
                                HStack {
                                    Button("Cancel") { }
                                    if errorInfo.isRetryable {
                                        Button("Try Again") {
                                            self.onDonePressed(onDismiss: onDismiss)
                                        }
                                    }
                                }
                            )
                        }
                    )
                }
            }
        }
    }

    // MARK: HandleDidCheckEmailVerification
    func handleDidCheckEmailVerification(isVerified: Bool, onDismiss: @escaping @Sendable () -> Void) {
        if isVerified && !Task.isCancelled {
            handleNavigation()
            currentPollingTask?.cancel()
            currentPollingTask = nil
        } else if !Task.isCancelled {
            // Show alert if not verified
            router.showAlert(
                title: "Email not verified yet",
                subtitle: "Please click the verification link we sent to your email. You can resend the email or try checking again.",
                buttons: {
                    AnyView(
                        VStack {
                            Button("Resend Email") {
                                self.startSendVerificationEmail(
                                    isInitial: false,
                                    onDismiss: {
                                        onDismiss()
                                    }
                                )
                            }
                            Button("Check Again") {
                                self.onDonePressed(onDismiss: { onDismiss() })
                            }
                            Button("Cancel") { }
                        }
                    )
                }
            )
        }
    }

    // MARK: Handle Navigation

    func handleNavigation() {
        // Navigate based on user's current onboarding step
        let step = interactor.currentUser?.onboardingStep ?? .subscription
        interactor.trackEvent(event: Event.navigate)
        route(to: step)
    }

    private func route(to step: OnboardingStep) {
        switch step {
        case .auth, .subscription:
            // For anything at/before subscription, move them into complete-account setup
            router.showOnboardingCompleteAccountSetupView()

        case .completeAccountSetup:
            router.showOnboardingCompleteAccountSetupView()

        case .notifications:
            router.showOnboardingNotificationsView()

        case .healthData:
            router.showOnboardingHealthDataView()

        case .healthDisclaimer:
            router.showOnboardingHealthDisclaimerView()

        case .goalSetting:
            router.showOnboardingGoalSettingView()

        case .customiseProgram:
            router.showOnboardingCustomisingProgramView()

        case .complete:
            router.showOnboardingCompletedView()
        }
    }

    // MARK: - Timeout Helper
    @discardableResult
    func performAuthWithTimeout<T: Sendable>(_ operation: @escaping @Sendable () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(for: .seconds(AuthConstants.authTimeout))
                throw AuthTimeoutError.operationTimeout
            }

            guard let result = try await group.next() else {
                throw AuthTimeoutError.operationTimeout
            }

            group.cancelAll()
            return result
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    // MARK: - Alerts
    func showNotSignedInAlert(onDismiss: @escaping @Sendable () -> Void) {
        router.showAlert(
            title: "You're not signed in",
            subtitle: "Please sign in again to continue email verification.",
            buttons: {
                AnyView(
                    HStack {
                        Button("Cancel") { }
                        Button("Go to Sign In") {
                            onDismiss()
                        }
                    }
                )
            }
        )
    }

    // MARK: - Polling & Toast
    func startPolling() {
        // Avoid multiple polling tasks
        currentPollingTask?.cancel()
        currentPollingTask = Task {
            while !Task.isCancelled {
                // Don't poll while user actions are running
                if !isLoadingCheck && !isLoadingResend {
                    do {
                        let isVerified: Bool = try await performAuthWithTimeout {
                            try await self.interactor.checkVerificationEmail()
                        }
                        if isVerified && !Task.isCancelled {
                            handleNavigation()
                        }
                    } catch {
                        // Ignore transient polling errors
                    }
                }
                do {
                    try await Task.sleep(for: .seconds(pollIntervalSeconds))
                } catch { break }
            }
            // Clear reference when done
            currentPollingTask = nil
        }
    }

    func showToast(_ message: String) {
        withAnimation {
            toastMessage = message
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation {
                        if toastMessage == message {
                            toastMessage = nil
                        }
                    }
                }
            }
        }
    }

    func cleanUp() {
        // Clean up any ongoing tasks and reset loading states
        currentAuthTask?.cancel()
        currentAuthTask = nil
        currentPollingTask?.cancel()
        currentPollingTask = nil
        isLoadingCheck = false
        isLoadingResend = false
    }

    // MARK: Events
    enum Event: LoggableEvent {
        case sendEmailVerificationStart
        case sendEmailVerificationSuccess
        case sendEmailVerificationFail(error: Error)
        case checkEmailVerificationStart
        case checkEmailVerificationSuccess(isVerified: Bool)
        case checkEmailVerificationFail(error: Error)
        case navigate

        var eventName: String {
            switch self {
            case .sendEmailVerificationStart:    return "Onboarding_EmailVerification_SendStart"
            case .sendEmailVerificationSuccess:  return "Onboarding_EmailVerification_SendSuccess"
            case .sendEmailVerificationFail:     return "Onboarding_EmailVerification_SendFail"
            case .checkEmailVerificationStart:   return "Onboarding_EmailVerification_CheckStart"
            case .checkEmailVerificationSuccess: return "Onboarding_EmailVerification_CheckSuccess"
            case .checkEmailVerificationFail:    return "Onboarding_EmailVerification_CheckFail"
            case .navigate:                      return "EmailVerificationView_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .sendEmailVerificationFail(error: let error), .checkEmailVerificationFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .sendEmailVerificationFail, .checkEmailVerificationFail:
                return .severe
            case .navigate:
                return .info
            default:
                return .analytic
            }
        }
    }
}

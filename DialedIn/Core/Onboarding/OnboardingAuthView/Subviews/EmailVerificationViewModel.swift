//
//  EmailVerificationViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI

@MainActor
protocol EmailVerificationInteractor: Sendable {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    func sendVerificationEmail() async throws
    func checkVerificationEmail() async throws -> Bool
    func trackEvent(event: LoggableEvent)
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
}

extension CoreInteractor: EmailVerificationInteractor { }

@Observable
@MainActor
class EmailVerificationViewModel {
    private let interactor: EmailVerificationInteractor

    var isLoadingCheck: Bool = false
    var isLoadingResend: Bool = false
    var currentAuthTask: Task<Void, Never>?
    var currentPollingTask: Task<Void, Never>?
    private(set) var toastMessage: String?
    var navigationDestination: NavigationDestination?
    var showAlert: AnyAppAlert?
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    private let pollIntervalSeconds: Double = 7

    init(
        interactor: EmailVerificationInteractor
    ) {
        self.interactor = interactor
    }

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
                    showAlert = AnyAppAlert(
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
                    showAlert = AnyAppAlert(
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

    func handleDidCheckEmailVerification(isVerified: Bool, onDismiss: @escaping @Sendable () -> Void) {
        if isVerified && !Task.isCancelled {
            // Navigate based on user's current onboarding step
            let step = interactor.currentUser?.onboardingStep
            let destination = getNavigationDestination(for: step)
            navigationDestination = destination
            // Stop polling on success
            currentPollingTask?.cancel()
            currentPollingTask = nil
        } else if !Task.isCancelled {
            // Show alert if not verified
            showAlert = AnyAppAlert(
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

    // MARK: - Alerts

    func showNotSignedInAlert(onDismiss: @escaping @Sendable () -> Void) {
        showAlert = AnyAppAlert(
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
        let myInteractor = interactor
        currentPollingTask = Task {
            while !Task.isCancelled {
                // Don't poll while user actions are running
                if !isLoadingCheck && !isLoadingResend {
                    do {
                        let isVerified: Bool = try await performAuthWithTimeout {
                            try await myInteractor.checkVerificationEmail()
                        }
                        if isVerified && !Task.isCancelled {
                            // Navigate based on user's current onboarding step
                            let step = myInteractor.currentUser?.onboardingStep
                            let destination = getNavigationDestination(for: step)
                            navigationDestination = destination
                            break
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

    // MARK: - Helper Methods

    func getNavigationDestination(for step: OnboardingStep?) -> NavigationDestination? {
        switch step {
        case nil:
            return .subscription
        case .auth:
            // User hasn't progressed past auth, go to subscription
            return .subscription
        case .subscription:
            // User is at subscription step, go there
            return .subscription
        case .completeAccountSetup:
            // User is at complete account setup, go there
            return .completeAccountSetup
        case .healthDisclaimer:
            // User is at health disclaimer, go there
            return .healthDisclaimer
        case .goalSetting:
            // User is at goal setting, go there
            return .goalSetting
        case .customiseProgram:
            // User is at customise program, go there
            return .customiseProgram
        case .diet:
            return .diet
        case .complete:
            // User has completed onboarding, show main app
            return .completed
        }
    }

    enum Event: LoggableEvent {
        case sendEmailVerificationStart
        case sendEmailVerificationSuccess
        case sendEmailVerificationFail(error: Error)
        case checkEmailVerificationStart
        case checkEmailVerificationSuccess(isVerified: Bool)
        case checkEmailVerificationFail(error: Error)

        var eventName: String {
            switch self {
            case .sendEmailVerificationStart:    return "Onboarding_EmailVerification_SendStart"
            case .sendEmailVerificationSuccess:  return "Onboarding_EmailVerification_SendSuccess"
            case .sendEmailVerificationFail:     return "Onboarding_EmailVerification_SendFail"
            case .checkEmailVerificationStart:   return "Onboarding_EmailVerification_CheckStart"
            case .checkEmailVerificationSuccess: return "Onboarding_EmailVerification_CheckSuccess"
            case .checkEmailVerificationFail:    return "Onboarding_EmailVerification_CheckFail"
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
            default:
                return .analytic
            }
        }
    }
}

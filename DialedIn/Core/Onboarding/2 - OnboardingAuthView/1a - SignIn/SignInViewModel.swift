//
//  SignInViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI
import FirebaseAuth

protocol SignInInteractor: Sendable {
    // var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    func signInUser(email: String, password: String) async throws -> UserAuthInfo
    func logIn(auth: UserAuthInfo, image: PlatformImage?) async throws
    func checkVerificationEmail() async throws -> Bool
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
    func handleUserLoginError(_ error: Error) -> AuthErrorInfo
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: SignInInteractor { }

@MainActor
protocol SignInRouter {
    func showDevSettingsView()
    func showEmailVerificationView()
    func showOnboardingCompleteAccountSetupView()
    func showOnboardingNotificationsView()
    func showOnboardingHealthDataView()
    func showOnboardingHealthDisclaimerView()
    func showOnboardingGoalSettingView()
    func showOnboardingCustomisingProgramView()
    func showOnboardingCompletedView()
}

extension CoreRouter: SignInRouter { }

@Observable
@MainActor
class SignInViewModel {
    private let interactor: SignInInteractor
    private let router: SignInRouter

    var email: String = ""
    var password: String = ""
    var emailTouched: Bool = false
    var passwordTouched: Bool = false
    var isLoadingAuth: Bool = false
    var isLoadingUser: Bool = false
    var showAlert: AnyAppAlert?
    var currentAuthTask: Task<Void, Never>?
    
    var currentUser: UserModel? {
        interactor.currentUser
    }

    init(
        interactor: SignInInteractor,
        router: SignInRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: Sign In Pressed
    func onSignInPressed() {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {

            // Task Management
            isLoadingAuth = true
            defer {
                isLoadingAuth = false
                currentAuthTask = nil
            }
            
            interactor.trackEvent(event: Event.signInStart)
            do {
                try await performAuthWithTimeout {
                    let auth = try await self.interactor.signInUser(email: self.email, password: self.password)
                    await self.interactor.trackEvent(event: Event.signInSuccess)
                    await self.handleOnAuthSuccess(user: auth)
                }

            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleAuthError(error, operation: "sign in") {
                        Task { @MainActor in
                            self.onSignInPressed()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Handle Auth Success
    func handleOnAuthSuccess(user: UserAuthInfo) {
        // Cancel any existing auth task to prevent conflicts
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {

            // Task Management
            isLoadingUser = true
            defer {
                isLoadingUser = false
                currentAuthTask = nil
            }
            
            interactor.trackEvent(event: Event.userLoginStart)
            do {
                try await performAuthWithTimeout {
                    try await self.interactor.logIn(auth: user, image: nil)
                }
                interactor.trackEvent(event: Event.userLoginSuccess)
                
                // Only navigate if task wasn't cancelled
                if !Task.isCancelled {
                    // For sign-in with existing auth, check email verification before proceeding
                    do {
                        let isVerified: Bool = try await performAuthWithTimeout {
                            try await self.interactor.checkVerificationEmail()
                        }
                        guard let user = currentUser else { throw AuthError.notSignedIn }
                        if isVerified, user.onboardingStep != .complete {
                            // Navigate based on user's current onboarding step
                            handleNavigation()
                        } else if isVerified, user.onboardingStep == .complete {
                            interactor.updateAppState(showTabBarView: true)
                        } else {
                            interactor.trackEvent(event: Event.navigate)
                            router.showEmailVerificationView()
                        }
                    } catch {
                        // Reuse login error handler to allow retry
                        handleUserLoginError(error) {
                            Task { @MainActor in
                                self.handleOnAuthSuccess(user: user)
                            }
                        }
                    }
                }
            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleUserLoginError(error) {
                        Task { @MainActor in
                            self.handleOnAuthSuccess(user: user)
                        }
                    }
                }
            }
        }
    }

    // MARK: Handle Navigation
    func handleNavigation() {
        if let currentUser = interactor.currentUser {
            let step = currentUser.onboardingStep
            interactor.trackEvent(event: Event.navigate)
            route(to: step)
        }
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

    // MARK: Auth w/ Timeout
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

    // MARK: Auth Error
    func handleAuthError(_ error: Error, operation: String, retryAction: @escaping @Sendable () -> Void) {
        let errorInfo = interactor.handleAuthError(error, operation: operation)
        
        showAlert = AnyAppAlert(
            title: errorInfo.title,
            subtitle: errorInfo.message,
            buttons: {
                AnyView(
                    HStack {
                        Button("Cancel") { }
                        if errorInfo.isRetryable {
                            Button("Try Again") {
                                retryAction()
                            }
                        }
                    }
                )
            }
        )
    }
    
    // MARK: User Error
    func handleUserLoginError(_ error: Error, retryAction: @escaping @Sendable () -> Void) {
        let errorInfo = interactor.handleUserLoginError(error)
        
        showAlert = AnyAppAlert(
            title: errorInfo.title,
            subtitle: errorInfo.message,
            buttons: {
                AnyView(
                    HStack {
                        Button("Cancel") { }
                        if errorInfo.isRetryable {
                            Button("Try Again") {
                                retryAction()
                            }
                        }
                    }
                )
            }
        )
    }

    func cleanup() {
        // Clean up any ongoing tasks and reset loading states
        currentAuthTask?.cancel()
        currentAuthTask = nil
        isLoadingAuth = false
        isLoadingUser = false
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    // MARK: - Events
    enum Event: LoggableEvent {
        case signInStart
        case signInSuccess
        case signInFail(error: Error)
        case userLoginStart
        case userLoginSuccess
        case userLoginFail(error: Error)
        case navigate
        
        var eventName: String {
            switch self {
            case .signInStart:      return "EmailAuthView_SignIn_Start"
            case .signInSuccess:    return "EmailAuthView_SignIn_Success"
            case .signInFail:       return "EmailAuthView_SignIn_Fail"
            case .userLoginStart:   return "EmailAuthView_UserLogin_Start"
            case .userLoginSuccess: return "EmailAuthView_UserLogin_Success"
            case .userLoginFail:    return "EmailAuthView_UserLogin_Fail"
            case .navigate:         return "SignInView_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .signInFail(error: let error), .userLoginFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signInFail, .userLoginFail:
                return .severe
            case .navigate:
                return .info
            default:
                return .analytic
                
            }
        }
    }
    
    // MARK: - Validation
    
    var emailValidationError: String? {
        let trimmed = (email).trimmingCharacters(in: .whitespacesAndNewlines)
        guard emailTouched else { return nil }
        if trimmed.isEmpty { return "Email is required" }
        if !isValidEmail(trimmed) { return "Enter a valid email" }
        return nil
    }
    
    var passwordValidationError: String? {
        let value = password
        guard passwordTouched else { return nil }
        if value.isEmpty { return "Password is required" }
        
        return nil
    }
    
    var canSubmit: Bool {
        let emailOk = emailValidationError == nil && !(email).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let passwordOk = passwordValidationError == nil && !(password).isEmpty
        
        return emailOk && passwordOk
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", pattern)
        return predicate.evaluate(with: email)
    }
}

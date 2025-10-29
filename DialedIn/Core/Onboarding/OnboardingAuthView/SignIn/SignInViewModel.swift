//
//  SignInViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI
import FirebaseAuth

protocol SignInInteractor: Sendable {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    func signInUser(email: String, password: String) async throws -> UserAuthInfo
    func logIn(auth: UserAuthInfo, image: PlatformImage?) async throws
    func checkVerificationEmail() async throws -> Bool
    func trackEvent(event: LoggableEvent)
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
    func handleUserLoginError(_ error: Error) -> AuthErrorInfo
}

extension CoreInteractor: SignInInteractor { }

@Observable
@MainActor
class SignInViewModel {
    private let interactor: SignInInteractor
    
    var email: String = ""
    var password: String = ""
    var emailTouched: Bool = false
    var passwordTouched: Bool = false
    var isLoadingAuth: Bool = false
    var isLoadingUser: Bool = false
    var showAlert: AnyAppAlert?
    var currentAuthTask: Task<Void, Never>?
    var navigationDestination: NavigationDestination?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: SignInInteractor
    ) {
        self.interactor = interactor
    }
    
    func onSignInPressed() {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            isLoadingAuth = true
            defer {
                isLoadingAuth = false
                currentAuthTask = nil
            }
            
            interactor.trackEvent(event: Event.signInStart)
            do {
                try await performAuthWithTimeout {
                    let auth = try await self.interactor.signInUser(email: self.email, password: self.password)
                    await self.handleOnAuthSuccess(user: auth)
                }
                interactor.trackEvent(event: Event.signInSuccess)
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
    
    func handleOnAuthSuccess(user: UserAuthInfo) {
        // Cancel any existing auth task to prevent conflicts
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
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
                        if isVerified {
                            // Navigate based on user's current onboarding step
                            let step = interactor.currentUser?.onboardingStep
                            let destination = getNavigationDestination(for: step)
                            navigationDestination = destination
                        } else {
                            navigationDestination = .emailVerification
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
    
    func getNavigationDestination(for step: OnboardingStep?) -> NavigationDestination? {
        switch step {
        case nil:
            return .subscription
        case .auth:
            // User hasn't progressed past auth, go to subscription
            return .emailVerification
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
    
    /// Performs auth operation with timeout handling
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
    
    /// Standardized error handling for auth operations
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
    
    // MARK: - Error Messages
    // Note: Error message generation is now handled by AuthErrorHandler
    
    /// Standardized error handling for user login operations
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
    
    // MARK: - Events
    
    enum Event: LoggableEvent {
        case signInStart
        case signInSuccess
        case signInFail(error: Error)
        case userLoginStart
        case userLoginSuccess
        case userLoginFail(error: Error)
        
        var eventName: String {
            switch self {
            case .signInStart:      return "EmailAuthView_SignIn_Start"
            case .signInSuccess:    return "EmailAuthView_SignIn_Success"
            case .signInFail:       return "EmailAuthView_SignIn_Fail"
            case .userLoginStart:   return "EmailAuthView_UserLogin_Start"
            case .userLoginSuccess: return "EmailAuthView_UserLogin_Success"
            case .userLoginFail:    return "EmailAuthView_UserLogin_Fail"
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

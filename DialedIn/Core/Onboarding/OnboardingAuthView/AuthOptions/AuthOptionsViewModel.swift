//
//  AuthOptionsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

@Observable
@MainActor
class AuthOptionsViewModel {
    private let authManager: AuthManager
    private let userManager: UserManager
    private let logManager: LogManager
    
    private(set) var didTriggerLogin: Bool = false
    private(set) var currentAuthTask: Task<Void, Never>?
    
    var isLoading: Bool = false
    var showAlert: AnyAppAlert?
    var navigationDestination: NavigationDestination?

    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        container: DependencyContainer
    ) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    func endTask() {
        isLoading = false
        currentAuthTask = nil
    }
    
    func onSignInApplePressed() {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            // Task Management
            isLoading = true
            defer {
                endTask()
            }

            // Begin auth
            logManager.trackEvent(event: Event.appleAuthStart)
            do {
                // Get UserAuthInfo
                let result = try await authManager.signInApple()
                logManager.trackEvent(event: Event.appleAuthSuccess)
                
                // Proceed immediately to signing in the user on success
                handleOnAuthSuccess(user: result)
            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleAuthError(error, provider: "Apple") {
                        Task { @MainActor in
                            self.onSignInApplePressed()
                        }
                    }
                }
            }
        }
    }

    func onSignInGooglePressed() {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            // Task Management
            isLoading = true
            defer {
                endTask()
            }
            
            // Begin auth
            logManager.trackEvent(event: Event.googleAuthStart)
            do {
                let result = try await authManager.signInGoogle()
                logManager.trackEvent(event: Event.googleAuthSuccess)

                // Proceed immediately to signing in the user on success
                handleOnAuthSuccess(user: result)
            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleAuthError(error, provider: "Google") {
                        Task { @MainActor in
                            self.onSignInGooglePressed()
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
            
            didTriggerLogin = true
            // Task Management
            isLoading = true
            defer {
                endTask()
            }
            
            // Begin user login
            logManager.trackEvent(event: Event.userLoginStart)
            do {
                // Log in user
                try await userManager.logIn(auth: user)
                logManager.trackEvent(event: Event.userLoginSuccess)
                
                // Navigate to appropriate view
                handleNavigation()
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
    
    func handleNavigation() {
        // Navigate based on user's current onboarding step
        let destination = getNavigationDestination(for: userManager.currentUser?.onboardingStep ?? .auth)
        navigationDestination = destination
    }
    
    // MARK: - Helper Methods
    
    /// Maps UserManager.OnboardingStep to NavigationDestination
    func getNavigationDestination(for step: OnboardingStep) -> NavigationDestination? {
        switch step {
        case .auth:
            // SSO users should skip email verification and go straight to subscription
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
            // User has completed onboarding, navigate to TabBarView
            return .completed
        }
    }
    
    /// Standardized error handling for auth operations
    func handleAuthError(_ error: Error, provider: String, retryAction: @escaping @Sendable () -> Void) {
        let errorInfo = AuthErrorHandler.handle(error, operation: "sign in", provider: provider, logManager: logManager)
        
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
    
    /// Standardized error handling for user login operations
    func handleUserLoginError(_ error: Error, retryAction: @escaping @Sendable () -> Void) {
        let errorInfo = AuthErrorHandler.handleUserLoginError(error, logManager: logManager)
        
        showAlert = AnyAppAlert(
            title: errorInfo.title,
            subtitle: errorInfo.message,
            buttons: {
                AnyView(
                    HStack {
                        Button {
                            self.didTriggerLogin = false
                        } label: {
                            Text("Cancel")
                        }
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
    
    func cleanUp() {
        currentAuthTask?.cancel()
        currentAuthTask = nil
        isLoading = false
    }
    
    // MARK: - Error Messages
    // Note: Error message generation is now handled by AuthErrorHandler

    enum Event: LoggableEvent {
        case appleAuthStart
        case appleAuthSuccess
        case appleAuthFail(error: Error)

        case googleAuthStart
        case googleAuthSuccess
        case googleAuthFail(error: Error)

        case userLoginStart
        case userLoginSuccess
        case userLoginFail(error: Error)
        var eventName: String {
            switch self {
            case .appleAuthStart:    return "OnboardingAuth_AppleAuth_Start"
            case .appleAuthSuccess:  return "OnboardingAuth_AppleAuth_Success"
            case .appleAuthFail:     return "OnboardingAuth_AppleAuth_Fail"
            case .googleAuthStart:   return "OnboardingAuth_GoogleAuth_Start"
            case .googleAuthSuccess: return "OnboardingAuth_GoogleAuth_Success"
            case .googleAuthFail:    return "OnboardingAuth_GoogleAuth_Fail"
            case .userLoginStart:    return "OnboardingAuth_UserLogin_Start"
            case .userLoginSuccess:  return "OnboardingAuth_UserLogin_Success"
            case .userLoginFail:     return "OnboardingAuth_UserLogin_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .appleAuthFail(error: let error), .googleAuthFail(error: let error), .userLoginFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .appleAuthFail, .googleAuthFail, .userLoginFail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}

enum NavigationDestination {
    
    case emailVerification
    case subscription
    case completeAccountSetup
    case healthData
    case notifications
    case gender
    case healthDisclaimer
    case goalSetting
    case customiseProgram
    case diet
    case completed
}

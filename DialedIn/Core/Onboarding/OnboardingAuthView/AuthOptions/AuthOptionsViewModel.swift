//
//  AuthOptionsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

protocol AuthOptionsInteractor {
    var currentUser: UserModel? { get }
    func signInApple() async throws -> UserAuthInfo
    func signInGoogle() async throws -> UserAuthInfo
    func logIn(auth: UserAuthInfo, image: PlatformImage?) async throws
    func trackEvent(event: LoggableEvent)
    func handleAuthError(_ error: Error, operation: String, provider: String?) -> AuthErrorInfo
    func handleUserLoginError(_ error: Error) -> AuthErrorInfo
}

extension CoreInteractor: AuthOptionsInteractor { }

@Observable
@MainActor
class AuthOptionsViewModel {
    private let interactor: AuthOptionsInteractor
    
    private(set) var didTriggerLogin: Bool = false
    private(set) var currentAuthTask: Task<Void, Never>?
    
    var isLoading: Bool = false
    var showAlert: AnyAppAlert?
    var navigationDestination: NavigationDestination?

    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: AuthOptionsInteractor,
    ) {
        self.interactor = interactor
    }
    
    func endTask() {
        isLoading = false
        currentAuthTask = nil
    }
    
    func onSignInApplePressed(path: Binding<[OnboardingPathOption]>) {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            // Task Management
            isLoading = true
            defer {
                endTask()
            }

            // Begin auth
            interactor.trackEvent(event: Event.appleAuthStart)
            do {
                // Get UserAuthInfo
                let result = try await interactor.signInApple()
                interactor.trackEvent(event: Event.appleAuthSuccess)

                // Proceed immediately to signing in the user on success
                handleOnAuthSuccess(user: result, path: path)
            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleAuthError(error, provider: "Apple") {
                        Task { @MainActor in
                            self.onSignInApplePressed(path: path)
                        }
                    }
                }
            }
        }
    }

    func onSignInGooglePressed(path: Binding<[OnboardingPathOption]>) {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            // Task Management
            isLoading = true
            defer {
                endTask()
            }
            
            // Begin auth
            interactor.trackEvent(event: Event.googleAuthStart)
            do {
                let result = try await interactor.signInGoogle()
                interactor.trackEvent(event: Event.googleAuthSuccess)

                // Proceed immediately to signing in the user on success
                handleOnAuthSuccess(user: result, path: path)
            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleAuthError(error, provider: "Google") {
                        Task { @MainActor in
                            self.onSignInGooglePressed(path: path)
                        }
                    }
                }
            }
        }
    }
    
    func handleOnAuthSuccess(user: UserAuthInfo, path: Binding<[OnboardingPathOption]>) {
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
            interactor.trackEvent(event: Event.userLoginStart)
            do {
                // Log in user
                try await interactor.logIn(auth: user, image: nil)
                interactor.trackEvent(event: Event.userLoginSuccess)

                // Navigate to appropriate view
                handleNavigation(path: path)
            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleUserLoginError(error) {
                        Task { @MainActor in
                            self.handleOnAuthSuccess(user: user, path: path)
                        }
                    }
                }
            }
        }
    }
    
    func handleNavigation(path: Binding<[OnboardingPathOption]>) {
        // Navigate based on user's current onboarding step
        
        path.wrappedValue.append(.subscriptionInfo)
//        let destination = getNavigationDestination(for: interactor.currentUser?.onboardingStep ?? .auth)
//        navigationDestination = destination
    }
    
    // MARK: - Helper Methods
    
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
        let errorInfo = interactor.handleAuthError(error, operation: "sign in", provider: provider)
        
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
        let errorInfo = interactor.handleUserLoginError(error)
        
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
    
    func signUpPressed(path: Binding<[OnboardingPathOption]>) {
        interactor.trackEvent(event: Event.signUpPressed)
        path.wrappedValue.append(.signUp)
    }
    
    func signInPressed(path: Binding<[OnboardingPathOption]>) {
        interactor.trackEvent(event: Event.signUpPressed)
        path.wrappedValue.append(.signIn)
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

        case signInPressed
        case signUpPressed
        
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
            case .signInPressed:     return "OnboardingAuth_SignIn_Pressed"
            case .signUpPressed:     return "OnboardingAuth_SignUp_Pressed"
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
                return LogType.severe
            case .signInPressed, .signUpPressed:
                return LogType.info
            default:
                return LogType.analytic

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

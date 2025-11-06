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
    func handleAuthError(_ error: Error, operation: String, provider: String?) -> AuthErrorInfo
    func handleUserLoginError(_ error: Error) -> AuthErrorInfo
    func trackEvent(event: LoggableEvent)
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

    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: AuthOptionsInteractor) {
        self.interactor = interactor
    }
    
    func endTask() {
        isLoading = false
        currentAuthTask = nil
    }
    
    // MARK: Sign In Apple
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

    // MARK: Sign In Google
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
    
    // MARK: User Log In
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
    
    // MARK: Handle Navigation
    func handleNavigation(path: Binding<[OnboardingPathOption]>) {
        // Navigate based on user's current onboarding step
        if let currentUser = interactor.currentUser {
            let pathOption = currentUser.onboardingStep.onboardingPathOption
            interactor.trackEvent(event: Event.navigate(destination: pathOption))
            path.wrappedValue.append(pathOption)
        }
    }
    
    // MARK: Auth Error
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
    
    // MARK: User Error
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
    
    // MARK: Sign Up Pressed
    func signUpPressed(path: Binding<[OnboardingPathOption]>) {
        interactor.trackEvent(event: Event.signUpPressed)
        path.wrappedValue.append(.signUp)
    }
    
    // MARK: Sign In Pressed
    func signInPressed(path: Binding<[OnboardingPathOption]>) {
        interactor.trackEvent(event: Event.signUpPressed)
        path.wrappedValue.append(.signIn)
    }
    
    // MARK: Cleanup Tasks
    func cleanUp() {
        currentAuthTask?.cancel()
        currentAuthTask = nil
        isLoading = false
    }
    
    // MARK: Events
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

        case navigate(destination: OnboardingPathOption)
        case signInPressed
        case signUpPressed

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
            case .navigate:          return "OnboardingAuth_Navigate"
            case .signInPressed:     return "OnboardingAuth_SignIn_Pressed"
            case .signUpPressed:     return "OnboardingAuth_SignUp_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .appleAuthFail(error: let error), .googleAuthFail(error: let error), .userLoginFail(error: let error):
                return error.eventParameters
            case .navigate(destination: let destination):
                return destination.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .appleAuthFail, .googleAuthFail, .userLoginFail:
                return LogType.severe
            case .signInPressed, .signUpPressed, .navigate:
                return LogType.info
            default:
                return LogType.analytic

            }
        }
    }
}

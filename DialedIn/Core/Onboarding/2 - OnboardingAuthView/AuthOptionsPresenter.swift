//
//  OnboardingAuthPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import SwiftfulRouting

@Observable
@MainActor
class OnboardingAuthPresenter {
    private let interactor: OnboardingAuthInteractor
    private let router: OnboardingAuthRouter

    private(set) var didTriggerLogin: Bool = false
    private(set) var currentAuthTask: Task<Void, Never>?
    
    var currentUser: UserModel? {
        interactor.currentUser
    }

    init(
        interactor: OnboardingAuthInteractor,
        router: OnboardingAuthRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func endTask() {
        router.dismissModal()
        currentAuthTask = nil
    }
    
    // MARK: Sign In Apple
    func onSignInApplePressed() {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            // Task Management
            router.showLoadingModal()

            defer {
                endTask()
            }

            // Begin auth
            interactor.trackEvent(event: Event.appleAuthStart)
            do {
                // Get UserAuthInfo
                let (userAuthInfo, isNewUser) = try await interactor.signInApple()
                interactor.trackEvent(event: Event.appleAuthSuccess)

                // Proceed immediately to signing in the user on success
                handleOnAuthSuccess(user: userAuthInfo, isNewUser: isNewUser)
            } catch {
                router.showAlert(
                    title: "Error Signing in with Apple",
                    subtitle: "Please check your internet connection and try again",
                    buttons: {
                        AnyView(
                            HStack {
                                Button("Cancel") { }
                                Button("Try Again") {
                                    self.onSignInApplePressed()
                                }
                            }
                        )
                    }
                )
            }
        }
    }

    // MARK: Sign In Google
    func onSignInGooglePressed() {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            // Task Management
            router.showLoadingModal()

            defer {
                endTask()
            }
            
            // Begin auth
            interactor.trackEvent(event: Event.googleAuthStart)
            do {
                let (userAuthInfo, isNewUser) = try await interactor.signInGoogle()
                interactor.trackEvent(event: Event.googleAuthSuccess)

                // Proceed immediately to signing in the user on success
                handleOnAuthSuccess(user: userAuthInfo, isNewUser: isNewUser)
            } catch {
                router.showAlert(
                    title: "Error Signing in with Google",
                    subtitle: "Please check your internet connection and try again",
                    buttons: {
                        AnyView(
                            HStack {
                                Button("Cancel") { }
                                Button("Try Again") {
                                    self.onSignInGooglePressed()
                                }
                            }
                        )
                    }
                )
            }
        }
    }
    
    // MARK: User Log In
    func handleOnAuthSuccess(user: UserAuthInfo, isNewUser: Bool) {
        // Cancel any existing auth task to prevent conflicts
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            
            didTriggerLogin = true
            // Task Management
            router.showLoadingModal()

            defer {
                endTask()
            }
            
            // Begin user login
            interactor.trackEvent(event: Event.userLoginStart)
            do {
                // Log in user
                try await interactor.logIn(auth: user, image: nil, isNewUser: isNewUser)
                interactor.trackEvent(event: Event.userLoginSuccess)
                
                guard let user = currentUser else { return }
                
                if interactor.isPremium == false {
                    // Non‑premium: go straight to paywall from auth
                    interactor.trackEvent(event: Event.paywallShownAfterLogin)
                    router.showOnbPaywall()
                } else if user.onboardingStep != .complete {
                    // Premium but still onboarding: continue onboarding
                    handleNavigation()
                } else {
                    // Premium and onboarding complete: go to main app
                    interactor.updateAppState(showTabBarView: true)
                }
            } catch {
                router.showAlert(
                    title: "Error Logging In",
                    subtitle: "Please check your internet connection and try again.",
                    buttons: {
                        AnyView(
                            HStack {
                                Button {
                                    self.didTriggerLogin = false
                                } label: {
                                    Text("Cancel")
                                }
                                Button("Try Again") {
                                    self.handleOnAuthSuccess(user: user, isNewUser: isNewUser)
                                }
                            }
                        )
                    }
                )
            }
        }
    }
    
    // MARK: Handle Navigation
    func handleNavigation() {
        // Navigate based on user's current onboarding step
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
            
    // MARK: Cleanup Tasks
    func cleanUp() {
        currentAuthTask?.cancel()
        currentAuthTask = nil
        
        router.dismissModal()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
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

        case navigate
        case signInPressed
        case signUpPressed
        case paywallShownAfterLogin

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
            case .paywallShownAfterLogin: return "OnboardingAuth_PaywallShownAfterLogin"
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
            case .signInPressed, .signUpPressed, .navigate, .paywallShownAfterLogin:
                return LogType.info
            default:
                return LogType.analytic

            }
        }
    }
}

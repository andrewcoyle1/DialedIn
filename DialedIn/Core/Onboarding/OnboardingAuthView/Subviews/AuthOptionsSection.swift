//
//  AuthOptionsSection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI
import AuthenticationServices

struct AuthOptionsSection: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(LogManager.self) private var logManager
    @Environment(UserManager.self) private var userManager
    @State private var showAlert: AnyAppAlert?

    @State private var navigateToSignIn: Bool = false
    @State private var navigateToSignUp: Bool = false
    @State private var navigateToSubscriptionView: Bool = false
    @State private var didTriggerLogin: Bool = false

    var body: some View {
        VStack {
            Spacer()
            appleSignInSection
            googleSignInSection
            signUpButtonSection
            signInButtonSection
        }
        .navigationDestination(isPresented: $navigateToSignIn) {
            EmailAuthSection(mode: .signIn)
        }
        .navigationDestination(isPresented: $navigateToSignUp) {
            EmailAuthSection(mode: .signUp)
        }
        .navigationDestination(isPresented: $navigateToSubscriptionView) {
            OnboardingSubscriptionView()
        }
        .showCustomAlert(alert: $showAlert)
        .task {
            if let user = authManager.auth {
                didTriggerLogin = true
                handleOnAuthSuccess(user: user)
            }
        }
        .onChange(of: authManager.auth, { _, newValue in
            if let newValue = newValue {
                didTriggerLogin = true
                handleOnAuthSuccess(user: newValue)
            }
        })
        .safeAreaInset(edge: .bottom) {
            tsAndCsSection
        }
    }

    private var appleSignInSection: some View {
        SignInWithAppleButtonView(type: .continue, style: .black, cornerRadius: 28)
            .frame(height: 56)
            .anyButton(.press) {
                onSignInApplePressed()
            }
            .padding(.horizontal)
    }

    private var googleSignInSection: some View {
        SignInWithGoogleButtonView(style: .light, scheme: .continueWithGoogle) { onSignInGooglePressed() }
            .frame(height: 56)
    }

    private var signUpButtonSection: some View {
        SignUpWithEmailButton {
            onSignUpEmailPressed()
        }
    }

    private var signInButtonSection: some View {
        Text("Sign In")
            .foregroundStyle(Color.secondary)
            .padding(.top, 8)
            .anyButton(.press) {
                onSignInEmailPressed()
            }
    }

    private var tsAndCsSection: some View {
        Text("By continuing, you agree to our [Terms of Service](Constants.termsofServiceURL) and [Privacy Policy](Constants.privacyPolicyURL)")
            .font(.caption)
            .foregroundStyle(Color.secondary)
            .padding(.horizontal)
            .padding(.top)
    }

    private func onSignInApplePressed() {
        Task {
            logManager.trackEvent(event: Event.appleAuthStart)
            do {
                try await authManager.signInApple()
                logManager.trackEvent(event: Event.appleAuthSuccess)
            } catch {
                logManager.trackEvent(event: Event.appleAuthFail(error: error))
                showAlert = AnyAppAlert(title: "Unable to continue with Apple", subtitle: "Please check your internet connection and try again.")
            }
        }
    }

    private func onSignInGooglePressed() {
        Task {
            logManager.trackEvent(event: Event.googleAuthStart)
            do {
                try await authManager.signInGoogle()
                logManager.trackEvent(event: Event.googleAuthSuccess)
            } catch {
                logManager.trackEvent(event: Event.googleAuthFail(error: error))
                showAlert = AnyAppAlert(title: "Unable to continue with Google", subtitle: "Please check your internet connection and try again.")
            }
        }
    }

    private func onSignUpEmailPressed() {
        navigateToSignUp = true
    }

    private func onSignInEmailPressed() {
        navigateToSignIn = true
    }
    
    private func handleOnAuthSuccess(user: UserAuthInfo) {
        logManager.trackEvent(event: Event.userLoginStart)
        Task {
            do {
                try await userManager.logIn(auth: user)
                logManager.trackEvent(event: Event.userLoginSuccess)

                navigateToSubscriptionView = true
            } catch {
                logManager.trackEvent(event: Event.userLoginFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Unable to log in to your account",
                    subtitle: "Please check your internet connection and try again.",
                    buttons: {
                        AnyView(
                            HStack {
                                Button {
                                    didTriggerLogin = false
                                } label: {
                                    Text("Dismiss")
                                }
                                Button {
                                    handleOnAuthSuccess(user: user)
                                } label: {
                                    Text("Try again")
                                }
                            }
                        )
                    }
                )
            }
        }
    }

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

#Preview("Functioning Auth") {
    @Previewable @State var userAuth: UserAuthInfo?
    @Previewable @State var isNewUser: Bool = false
    NavigationStack {
        AuthOptionsSection()
            .environment(AuthManager(service: MockAuthService(user: nil)))
    }
    .previewEnvironment()
}

#Preview("Slow Auth") {
    NavigationStack {
        AuthOptionsSection()
    }
    .environment(AuthManager(service: MockAuthService(delay: 3)))
    .previewEnvironment()
}

#Preview("Failing Auth") {
    NavigationStack {
        AuthOptionsSection()
    }
    .environment(AuthManager(service: MockAuthService(user: nil, showError: true)))
    .previewEnvironment()
}

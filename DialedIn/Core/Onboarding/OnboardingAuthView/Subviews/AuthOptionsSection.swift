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
    @Environment(AppState.self) private var appState
    @State private var showAlert: AnyAppAlert?

    @State private var navigationDestination: NavigationDestination?
    @State private var didTriggerLogin: Bool = false

    @State private var isLoadingAuth: Bool = false
    @State private var isLoadingUser: Bool = false
    @State private var currentAuthTask: Task<Void, Never>?
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    var body: some View {
        VStack {
            imageSection
            appleSignInSection
            googleSignInSection
            signUpButtonSection
            signInButtonSection
        }
        .toolbar {
            #if DEBUG || MOCK
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showDebugView = true
                } label: {
                    Image(systemName: "info")
                }
            }
            #endif
        }
        .modifier(NavigationDestinationsModifier(navigationDestination: $navigationDestination))
//        .navigationDestination(isPresented: Binding(
//            get: { navigationDestination == .auth },
//            set: { if !$0 { navigationDestination = nil } }
//        )) {
//            EmailVerificationView()
//        }
//        .navigationDestination(isPresented: Binding(
//            get: { navigationDestination == .subscription },
//            set: { if !$0 { navigationDestination = nil } }
//        )) {
//            OnboardingSubscriptionView()
//        }
//        .navigationDestination(isPresented: Binding(
//            get: { navigationDestination == .completeAccountSetup },
//            set: { if !$0 { navigationDestination = nil } }
//        )) {
//            OnboardingCompleteAccountSetupView()
//        }
//        .navigationDestination(isPresented: Binding(
//            get: { navigationDestination == .healthDisclaimer },
//            set: { if !$0 { navigationDestination = nil } }
//        )) {
//            OnboardingHealthDisclaimerView()
//        }
//        .navigationDestination(isPresented: Binding(
//            get: { navigationDestination == .goalSetting },
//            set: { if !$0 { navigationDestination = nil } }
//        )) {
//            OnboardingGoalSettingView()
//        }
//        .navigationDestination(isPresented: Binding(
//            get: { navigationDestination == .customiseProgram },
//            set: { if !$0 { navigationDestination = nil } }
//        )) {
//            OnboardingPreferredDietView()
//        }
//        .navigationDestination(isPresented: Binding(
//            get: { navigationDestination == .diet },
//            set: { if !$0 { navigationDestination = nil } }
//        )) {
//            OnboardingDietPlanView()
//        }
        .showCustomAlert(alert: $showAlert)
        .onChange(of: authManager.auth, { _, newValue in
            if let newValue = newValue {
                handleOnAuthSuccess(user: newValue)
            }
        })
        .safeAreaInset(edge: .bottom) {
            tsAndCsSection
        }
        .showModal(showModal: $isLoadingUser) {
            ProgressView()
                .tint(.white)
        }
        .onDisappear {
            // Clean up any ongoing tasks and reset loading states
            currentAuthTask?.cancel()
            currentAuthTask = nil
            isLoadingAuth = false
            isLoadingUser = false
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
        #endif
    }

    private var imageSection: some View {
        ImageLoaderView()
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                Text("DialedIn")
                    .font(.system(size: 64))
                    .fontDesign(.default)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.white)
                    .opacity(0.8)
                    .padding()
                    
            }
    }
    private var appleSignInSection: some View {
        SignInWithAppleButtonView(type: .continue, style: .black, cornerRadius: AuthConstants.buttonCornerRadius)
            .frame(height: AuthConstants.buttonHeight)
            .allowsHitTesting(!isLoadingAuth && !isLoadingUser)
            .anyButton(.press) {
                onSignInApplePressed()
            }
            .padding(.horizontal)
    }

    private var googleSignInSection: some View {
        SignInWithGoogleButtonView(style: .light, scheme: .continueWithGoogle) { onSignInGooglePressed() }
            .frame(height: AuthConstants.buttonHeight)
            .allowsHitTesting(!isLoadingAuth && !isLoadingUser)
    }

    private var signUpButtonSection: some View {
        NavigationLink {
            SignUpView()
        } label: {
            HStack {
                Text("Sign Up With Email")
                    .font(.system(size: 21))
            }
            .frame(maxWidth: .infinity)
            .frame(height: AuthConstants.buttonHeight/1.5)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
    }

    private var signInButtonSection: some View {
        NavigationLink {
            SignInView()
        } label: {
            HStack {
                Text("Sign In With Email")
                    .font(.system(size: 21))
            }
            .frame(maxWidth: .infinity)
            .frame(height: AuthConstants.buttonHeight/1.5)
        }
        .buttonStyle(.bordered)
        .padding(.horizontal)
    }

    private var tsAndCsSection: some View {
        Text("By continuing, you agree to our [Terms of Service](Constants.termsofServiceURL) and [Privacy Policy](Constants.privacyPolicyURL)")
            .font(.caption)
            .foregroundStyle(Color.secondary)
            .padding(.horizontal)
            .padding(.top)
    }

    private func onSignInApplePressed() {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            isLoadingAuth = true
            defer {
                isLoadingAuth = false
                currentAuthTask = nil
            }
            
            logManager.trackEvent(event: Event.appleAuthStart)
            do {
                // Ensure we have an anonymous user to link to, avoiding new UID creation
                if authManager.auth == nil {
                    _ = try await authManager.signInAnonymously()
                }
                try await authManager.signInApple()
                logManager.trackEvent(event: Event.appleAuthSuccess)
                // Navigation will be handled by handleOnAuthSuccess via onChange
            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleAuthError(error, provider: "Apple") {
                        Task { @MainActor in
                            onSignInApplePressed()
                        }
                    }
                }
            }
        }
    }

    private func onSignInGooglePressed() {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            isLoadingAuth = true
            defer {
                isLoadingAuth = false
                currentAuthTask = nil
            }
            
            logManager.trackEvent(event: Event.googleAuthStart)
            do {
                // Ensure we have an anonymous user to link to, avoiding new UID creation
                if authManager.auth == nil {
                    _ = try await authManager.signInAnonymously()
                }
                try await authManager.signInGoogle()
                logManager.trackEvent(event: Event.googleAuthSuccess)
                // Navigation will be handled by handleOnAuthSuccess via onChange
            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleAuthError(error, provider: "Google") {
                        Task { @MainActor in
                            onSignInGooglePressed()
                        }
                    }
                }
            }
        }
    }
    
    private func handleOnAuthSuccess(user: UserAuthInfo) {
        // Cancel any existing auth task to prevent conflicts
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            didTriggerLogin = true
            isLoadingUser = true
            defer {
                isLoadingUser = false
                currentAuthTask = nil
            }
            
            logManager.trackEvent(event: Event.userLoginStart)
            do {
                try await userManager.logIn(auth: user)
                logManager.trackEvent(event: Event.userLoginSuccess)
                handleNavigation()
            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleUserLoginError(error) {
                        Task { @MainActor in
                            handleOnAuthSuccess(user: user)
                        }
                    }
                }
            }
        }
    }
    
    private func handleNavigation() {
        // Navigate based on user's current onboarding step
        let destination = getNavigationDestination(for: userManager.currentUser?.onboardingStep ?? .auth)
        if destination == .completed {
            // User has completed onboarding, show main app
            appState.updateViewState(showTabBarView: true)
        } else {
            navigationDestination = destination
        }
    }
    
    // MARK: - Helper Methods
    
    /// Maps UserManager.OnboardingStep to NavigationDestination
    private func getNavigationDestination(for step: OnboardingStep) -> NavigationDestination? {
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
    private func handleAuthError(_ error: Error, provider: String, retryAction: @escaping @Sendable () -> Void) {
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
    private func handleUserLoginError(_ error: Error, retryAction: @escaping @Sendable () -> Void) {
        let errorInfo = AuthErrorHandler.handleUserLoginError(error, logManager: logManager)
        
        showAlert = AnyAppAlert(
            title: errorInfo.title,
            subtitle: errorInfo.message,
            buttons: {
                AnyView(
                    HStack {
                        Button {
                            didTriggerLogin = false
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

// MARK: - Constants and Error Types
// Note: AuthConstants and AuthTimeoutError are now defined in AuthErrorHandler.swift

#Preview("Functioning Auth") {
    @Previewable @State var userAuth: UserAuthInfo?
    @Previewable @State var isNewUser: Bool = false
    NavigationStack {
        AuthOptionsSection()
    }
    .environment(AuthManager(service: MockAuthService(user: nil)))
    .environment(UserManager(services: MockUserServices(user: .mock)))
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

#Preview("Slow Login") {
    NavigationStack {
        AuthOptionsSection()
    }
    .environment(UserManager(services: MockUserServices(user: nil, delay: 3)))
    .previewEnvironment()
}

#Preview("Failing Login") {
    NavigationStack {
        AuthOptionsSection()
    }
    .environment(UserManager(services: MockUserServices(user: nil, showError: true)))
    .previewEnvironment()
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

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

    @State private var navigationDestination: NavigationDestination?
    @State private var didTriggerLogin: Bool = false

    @State private var isLoadingAuth: Bool = false
    @State private var isLoadingUser: Bool = false
    @State private var currentAuthTask: Task<Void, Never>?
    
    enum NavigationDestination {
        case signIn
        case signUp
        case subscription
    }

    var body: some View {
        VStack {
            Spacer()
            appleSignInSection
            googleSignInSection
            signUpButtonSection
            signInButtonSection
        }
        .navigationDestination(isPresented: Binding(
            get: { navigationDestination == .signIn },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            EmailAuthSection(mode: .signIn)
        }
        .navigationDestination(isPresented: Binding(
            get: { navigationDestination == .signUp },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            EmailAuthSection(mode: .signUp)
        }
        .navigationDestination(isPresented: Binding(
            get: { navigationDestination == .subscription },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            OnboardingSubscriptionView()
        }
        .showCustomAlert(alert: $showAlert)
        .onChange(of: authManager.auth, { _, newValue in
            if let newValue = newValue {
                didTriggerLogin = true
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
                try await performAuthWithTimeout {
                    try await authManager.signInApple()
                }
                logManager.trackEvent(event: Event.appleAuthSuccess)
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
                try await performAuthWithTimeout {
                    try await authManager.signInGoogle()
                }
                logManager.trackEvent(event: Event.googleAuthSuccess)
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

    private func onSignUpEmailPressed() {
        navigationDestination = .signUp
    }

    private func onSignInEmailPressed() {
        navigationDestination = .signIn
    }
    
    private func handleOnAuthSuccess(user: UserAuthInfo) {
        // Cancel any existing auth task to prevent conflicts
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            isLoadingUser = true
            defer {
                isLoadingUser = false
                currentAuthTask = nil
            }
            
            logManager.trackEvent(event: Event.userLoginStart)
            do {
                try await performAuthWithTimeout {
                    try await userManager.logIn(auth: user)
                }
                logManager.trackEvent(event: Event.userLoginSuccess)

                // Only navigate if task wasn't cancelled
                if !Task.isCancelled {
                    navigationDestination = .subscription
                }
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
    
    // MARK: - Helper Methods
    
    /// Performs auth operation with timeout handling
    @discardableResult
    private func performAuthWithTimeout<T: Sendable>(_ operation: @escaping @Sendable () async throws -> T) async throws -> T {
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

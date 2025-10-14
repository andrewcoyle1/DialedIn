//
//  SignInView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI
import Foundation
import FirebaseAuth

struct SignInView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(AppState.self) private var appState
    
    @State var email: String = ""
    @State var password: String = ""
    
    @State private var emailTouched: Bool = false
    @State private var passwordTouched: Bool = false
    
    @State private var isLoadingAuth: Bool = false
    @State private var isLoadingUser: Bool = false
    
    @State private var showAlert: AnyAppAlert?
    @State private var currentAuthTask: Task<Void, Never>?
    @State private var navigationDestination: NavigationDestination?
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    var body: some View {
        List {
            emailSection
            passwordsSection
        }
        .navigationTitle("Sign In")
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .modifier(NavigationDestinationsModifier(navigationDestination: $navigationDestination))
        .showCustomAlert(alert: $showAlert)
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
    
    private var emailSection: some View {
        Section {
            TextField("Please enter your email",
                      text: $email
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .onChange(of: email) { _, _ in
                emailTouched = true
            }
            if let error = emailValidationError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.red)
            }
        } header: {
            Text("Email")
        }
    }
    
    private var passwordsSection: some View {
        Section {
            SecureField(
                "Please enter your password",
                text: $password
            )
            .textContentType(.password)
            .onChange(of: password) { _, _ in
                passwordTouched = true
            }
            
            if let error = passwordValidationError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.red)
            }
        } header: {
            Text("Password")
        }
    }
    
    // MARK: - Auth Functions
    
    private func onSignInPressed() {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            isLoadingAuth = true
            defer {
                isLoadingAuth = false
                currentAuthTask = nil
            }
            
            logManager.trackEvent(event: Event.signInStart)
            do {
                try await performAuthWithTimeout {
                    let auth = try await authManager.signInUser(email: email, password: password)
                    await handleOnAuthSuccess(user: auth)
                }
                logManager.trackEvent(event: Event.signInSuccess)
            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleAuthError(error, operation: "sign in") {
                        Task { @MainActor in
                            onSignInPressed()
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
                    // For sign-in with existing auth, check email verification before proceeding
                    do {
                        let isVerified: Bool = try await performAuthWithTimeout {
                            try await authManager.checkEmailVerification()
                        }
                        if isVerified {
                            // Navigate based on user's current onboarding step
                            let step = userManager.currentUser?.onboardingStep
                            let destination = getNavigationDestination(for: step)
                            if destination == .completed {
                                // User has completed onboarding, show main app
                                appState.updateViewState(showTabBarView: true)
                            } else {
                                navigationDestination = destination
                            }
                        } else {
                            navigationDestination = .emailVerification
                        }
                    } catch {
                        // Reuse login error handler to allow retry
                        handleUserLoginError(error) {
                            Task { @MainActor in
                                handleOnAuthSuccess(user: user)
                            }
                        }
                    }
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
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                onSignInPressed()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Maps UserManager.OnboardingStep to NavigationDestination
    private func getNavigationDestination(for step: OnboardingStep?) -> NavigationDestination? {
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
    private func handleAuthError(_ error: Error, operation: String, retryAction: @escaping @Sendable () -> Void) {
        let errorInfo = AuthErrorHandler.handle(error, operation: operation, logManager: logManager)
        
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
    private func handleUserLoginError(_ error: Error, retryAction: @escaping @Sendable () -> Void) {
        let errorInfo = AuthErrorHandler.handleUserLoginError(error, logManager: logManager)
        
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
    
    private var emailValidationError: String? {
        let trimmed = (email).trimmingCharacters(in: .whitespacesAndNewlines)
        guard emailTouched else { return nil }
        if trimmed.isEmpty { return "Email is required" }
        if !isValidEmail(trimmed) { return "Enter a valid email" }
        return nil
    }
    
    private var passwordValidationError: String? {
        let value = password
        guard passwordTouched else { return nil }
        if value.isEmpty { return "Password is required" }
        
        return nil
    }
    
    private var canSubmit: Bool {
        let emailOk = emailValidationError == nil && !(email).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let passwordOk = passwordValidationError == nil && !(password).isEmpty
        
        return emailOk && passwordOk
        
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", pattern)
        return predicate.evaluate(with: email)
    }
}

// MARK: - Navigation Destinations Modifier

struct NavigationDestinationsModifier: ViewModifier {
    @Binding var navigationDestination: NavigationDestination?
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .emailVerification },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                EmailVerificationView()
            }
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .subscription },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                OnboardingSubscriptionView()
            }
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .completeAccountSetup },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                OnboardingCompleteAccountSetupView()
            }
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .healthDisclaimer },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                OnboardingHealthDisclaimerView()
            }
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .goalSetting },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                OnboardingGoalSettingView()
            }
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .customiseProgram },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                OnboardingPreferredDietView()
            }
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .diet },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                OnboardingDietPlanView()
            }
    }
}

// MARK: - Constants and Error Types
// Note: AuthConstants and AuthTimeoutError are now defined in AuthErrorHandler.swift

#Preview("Sign In") {
    NavigationStack {
        SignInView()
    }
    .previewEnvironment()
}

#Preview("Sign In - Joe Bloggs") {
    NavigationStack {
        SignInView(email: "joebloggs@gmail.com", password: "password123")
    }
    .previewEnvironment()
}

#Preview("Sign In - Slow Loading") {
    NavigationStack {
        SignInView(email: "joebloggs@gmail.com", password: "password123")
    }
    .environment(AuthManager(service: MockAuthService(delay: 3), logManager: LogManager(services: [ConsoleService(printParameters: true)])))
    .previewEnvironment()
}

#Preview("Sign In - Failure") {
    NavigationStack {
        SignInView(email: "joebloggs@gmail.com", password: "password123")
    }
    .environment(AuthManager(service: MockAuthService(showError: true), logManager: LogManager(services: [ConsoleService(printParameters: true)])))
    .previewEnvironment()
}

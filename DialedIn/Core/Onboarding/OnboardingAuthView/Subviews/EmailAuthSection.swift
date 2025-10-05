//
//  SignInSection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI
import Foundation
import FirebaseAuth

struct EmailAuthSection: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(LogManager.self) private var logManager
    @Environment(UserManager.self) private var userManager
    
    let mode: EmailAuthSectionMode
    @State var email: String = ""
    @State var password: String = ""
    @State var passwordReenter: String = ""
    
    @State private var emailTouched: Bool = false
    @State private var passwordTouched: Bool = false
    @State private var passwordReenterTouched: Bool = false

    @State private var isLoadingAuth: Bool = false
    @State private var isLoadingUser: Bool = false
    @State private var showAlert: AnyAppAlert?
    @State private var currentAuthTask: Task<Void, Never>?
    @State private var navigationDestination: NavigationDestination?
    
    enum NavigationDestination {
        case emailVerification
        case subscription
    }
    
    var body: some View {
        List {
            emailSection
            passwordsSection
        }
        .navigationTitle(mode.description)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            buttonSection
        }
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
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $isLoadingUser) {
            ProgressView()
                .tint(.white)
        }
        .onChange(of: authManager.auth, { _, newValue in
            if let newValue = newValue {
                handleOnAuthSuccess(user: newValue)
            }
        })
        .onDisappear {
            // Clean up any ongoing tasks and reset loading states
            currentAuthTask?.cancel()
            currentAuthTask = nil
            isLoadingAuth = false
            isLoadingUser = false
        }
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
            SecureField("Please enter your password",
                        text: $password
            )
            .textContentType(mode == .signUp ? .newPassword : .password)
            .onChange(of: password) { _, _ in
                passwordTouched = true
            }

            if let error = passwordValidationError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.red)
            }

            if mode == .signUp {
                SecureField("Please re-enter your password",
                            text: $passwordReenter
                )
                .textContentType(.newPassword)
                .onChange(of: passwordReenter) { _, _ in passwordReenterTouched = true }

                if let error = passwordReenterValidationError {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(Color.red)
                }
            }
        } header: {
            Text("Password")
        }
    }
    
    private var buttonSection: some View {
        Capsule()
            .frame(height: AuthConstants.buttonHeight)
            .frame(maxWidth: .infinity)
            .foregroundStyle(canSubmit ? Color.accent : Color.gray.opacity(0.3))
            .padding(.horizontal)
            .overlay(alignment: .center) {
                if !isLoadingAuth && !isLoadingUser {
                    Text(mode.description)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 32)
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .allowsHitTesting(!isLoadingAuth && !isLoadingUser)
            .anyButton(.press) {
                if mode == .signIn {
                    onSignInPressed()
                } else {
                    onSignUpPressed()
                }
            }
    }

    enum EmailAuthSectionMode {
        case signIn
        case signUp

        var description: String {
            switch self {
            case .signIn: return "Sign In"
            case .signUp: return "Sign Up"
            }
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
                    try await authManager.signInUser(email: email, password: password)
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
    
    private func onSignUpPressed() {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            isLoadingAuth = true
            defer {
                isLoadingAuth = false
                currentAuthTask = nil
            }
            
            logManager.trackEvent(event: Event.signUpStart)
            do {
                try await performAuthWithTimeout {
                    try await authManager.createUser(email: email, password: password)
                }
                logManager.trackEvent(event: Event.signUpSuccess)
            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleAuthError(error, operation: "sign up") {
                        Task { @MainActor in
                            onSignUpPressed()
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
                    if mode == .signUp {
                        navigationDestination = .emailVerification
                    } else {
                        // For sign-in with existing auth, check email verification before proceeding
                        do {
                            let isVerified: Bool = try await performAuthWithTimeout {
                                try await authManager.checkEmailVerification()
                            }
                            if isVerified {
                                navigationDestination = .subscription
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
        case signUpStart
        case signUpSuccess
        case signUpFail(error: Error)
        case userLoginStart
        case userLoginSuccess
        case userLoginFail(error: Error)
        
        var eventName: String {
            switch self {
            case .signInStart:      return "EmailAuthView_SignIn_Start"
            case .signInSuccess:    return "EmailAuthView_SignIn_Success"
            case .signInFail:       return "EmailAuthView_SignIn_Fail"
            case .signUpStart:      return "EmailAuthView_SignUp_Start"
            case .signUpSuccess:    return "EmailAuthView_SignUp_Success"
            case .signUpFail:       return "EmailAuthView_SignUp_Fail"
            case .userLoginStart:   return "EmailAuthView_UserLogin_Start"
            case .userLoginSuccess: return "EmailAuthView_UserLogin_Success"
            case .userLoginFail:    return "EmailAuthView_UserLogin_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .signInFail(error: let error), .signUpFail(error: let error), .userLoginFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signInFail, .signUpFail, .userLoginFail:
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

        // Enforce strong policy only for sign up (no force-upgrade on sign-in)
        if mode == .signUp {
            if value.count < AuthConstants.passwordMinLength { return "Password must be at least \(AuthConstants.passwordMinLength) characters" }
            if value.count > AuthConstants.passwordMaxLength { return "Password must be at most \(AuthConstants.passwordMaxLength) characters" }

            let hasUppercase = value.rangeOfCharacter(from: .uppercaseLetters) != nil
            let hasLowercase = value.rangeOfCharacter(from: .lowercaseLetters) != nil
            let hasNumber = value.rangeOfCharacter(from: .decimalDigits) != nil
            let hasSpecial = value.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil

            if !hasUppercase || !hasLowercase || !hasNumber || !hasSpecial {
                return "Include uppercase, lowercase, number, and special character"
            }
        }

        return nil
    }

    private var passwordReenterValidationError: String? {
        guard mode == .signUp else { return nil }
        let value = passwordReenter
        guard passwordReenterTouched else { return nil }
        if value.isEmpty { return "Please re-enter your password" }
        if value != (password) { return "Passwords do not match" }
        return nil
    }

    private var canSubmit: Bool {
        let emailOk = emailValidationError == nil && !(email).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let passwordOk = passwordValidationError == nil && !(password).isEmpty
        switch mode {
        case .signIn:
            return emailOk && passwordOk
        case .signUp:
            let confirmOk = passwordReenterValidationError == nil && !(passwordReenter).isEmpty
            return emailOk && passwordOk && confirmOk
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", pattern)
        return predicate.evaluate(with: email)
    }
}

// MARK: - Constants and Error Types
// Note: AuthConstants and AuthTimeoutError are now defined in AuthErrorHandler.swift

#Preview("Sign In") {
    NavigationStack {
        EmailAuthSection(mode: .signIn)
    }
    .previewEnvironment()
}

#Preview("Sign In - Joe Bloggs") {
    NavigationStack {
        EmailAuthSection(mode: .signIn, email: "joebloggs@gmail.com", password: "password123")
    }
    .previewEnvironment()
}

#Preview("Sign In - Slow Loading") {
    NavigationStack {
        EmailAuthSection(mode: .signIn, email: "joebloggs@gmail.com", password: "password123")
    }
    .environment(AuthManager(service: MockAuthService(delay: 3), logManager: LogManager(services: [ConsoleService(printParameters: true)])))
    .previewEnvironment()
}

#Preview("Sign In - Failure") {
    NavigationStack {
        EmailAuthSection(mode: .signIn, email: "joebloggs@gmail.com", password: "password123")
    }
    .environment(AuthManager(service: MockAuthService(showError: true), logManager: LogManager(services: [ConsoleService(printParameters: true)])))
    .previewEnvironment()
}

#Preview("Sign Up") {
    NavigationStack {
        EmailAuthSection(mode: .signUp)
    }
    .previewEnvironment()
}

#Preview("Sign Up - Joe Bloggs") {
    NavigationStack {
        EmailAuthSection(mode: .signUp, email: "joebloggs@gmail.com", password: "password123", passwordReenter: "password123")
    }
    .previewEnvironment()
}

#Preview("Sign Up - Slow Loading") {
    NavigationStack {
        EmailAuthSection(mode: .signUp, email: "joebloggs@gmail.com", password: "password123", passwordReenter: "password123")
    }
    .environment(AuthManager(service: MockAuthService(delay: 3), logManager: LogManager(services: [ConsoleService(printParameters: true)])))
    .previewEnvironment()
}

#Preview("Sign Up - Failure") {
    NavigationStack {
        EmailAuthSection(mode: .signUp, email: "joebloggs@gmail.com", password: "password123", passwordReenter: "password123")
    }
    .environment(AuthManager(service: MockAuthService(showError: true), logManager: LogManager(services: [ConsoleService(printParameters: true)])))
    .previewEnvironment()
}

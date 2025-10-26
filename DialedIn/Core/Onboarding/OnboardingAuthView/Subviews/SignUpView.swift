//
//  SignInSection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI
import Foundation
import FirebaseAuth

struct SignUpView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
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
    }
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    var body: some View {
        List {
            emailSection
            passwordsSection
        }
        .navigationTitle("Sign Up")
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(
                viewModel: DevSettingsViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
        }
        #endif
        .navigationDestination(isPresented: Binding(
            get: { navigationDestination == .emailVerification },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            EmailVerificationView()
        }
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
            .textContentType(.newPassword)
            .onChange(of: password) { _, _ in
                passwordTouched = true
            }
            
            if let error = passwordValidationError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.red)
            }
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
        } header: {
            Text("Password")
        }
    }
    
    // MARK: - Auth Functions
    
    private func onSignUpPressed() {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        isLoadingAuth = true
        
        currentAuthTask = Task {
            defer {
                isLoadingAuth = false
                currentAuthTask = nil
            }
            
            logManager.trackEvent(event: Event.signUpStart)
            do {
                try await performAuthWithTimeout {
                    let auth = try await authManager.createUser(email: email, password: password)
                    await handleOnAuthSuccess(user: auth)
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
                    navigationDestination = .emailVerification
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
                onSignUpPressed()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
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
        case signUpStart
        case signUpSuccess
        case signUpFail(error: Error)
        case userLoginStart
        case userLoginSuccess
        case userLoginFail(error: Error)
        
        var eventName: String {
            switch self {
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
            case .signUpFail(error: let error), .userLoginFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signUpFail, .userLoginFail:
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
        if value.count < AuthConstants.passwordMinLength { return "Password must be at least \(AuthConstants.passwordMinLength) characters" }
        if value.count > AuthConstants.passwordMaxLength { return "Password must be at most \(AuthConstants.passwordMaxLength) characters" }
        
        let hasUppercase = value.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = value.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasNumber = value.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecial = value.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil
        
        if !hasUppercase || !hasLowercase || !hasNumber || !hasSpecial {
            return "Include uppercase, lowercase, number, and special character"
        }
    
        return nil
    }
    
    private var passwordReenterValidationError: String? {
        let value = passwordReenter
        guard passwordReenterTouched else { return nil }
        if value.isEmpty { return "Please re-enter your password" }
        if value != (password) { return "Passwords do not match" }
        return nil
    }
    
    private var canSubmit: Bool {
        let emailOk = emailValidationError == nil && !(email).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let passwordOk = passwordValidationError == nil && !(password).isEmpty
        let confirmOk = passwordReenterValidationError == nil && !(passwordReenter).isEmpty
        return emailOk && passwordOk && confirmOk
        
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", pattern)
        return predicate.evaluate(with: email)
    }
}

// MARK: - Constants and Error Types
// Note: AuthConstants and AuthTimeoutError are now defined in AuthErrorHandler.swift

#Preview("Sign Up") {
    NavigationStack {
        SignUpView()
    }
    .previewEnvironment()
}

#Preview("Sign Up - Joe Bloggs") {
    NavigationStack {
        SignUpView(email: "joebloggs@gmail.com", password: "password123", passwordReenter: "password123")
    }
    .previewEnvironment()
}

#Preview("Sign Up - Slow Loading") {
    NavigationStack {
        SignUpView(email: "joebloggs@gmail.com", password: "password123", passwordReenter: "password123")
    }
    .environment(AuthManager(service: MockAuthService(delay: 3), logManager: LogManager(services: [ConsoleService(printParameters: true)])))
    .previewEnvironment()
}

#Preview("Sign Up - Failure") {
    NavigationStack {
        SignUpView(email: "joebloggs@gmail.com", password: "password123", passwordReenter: "password123")
    }
    .environment(AuthManager(service: MockAuthService(showError: true), logManager: LogManager(services: [ConsoleService(printParameters: true)])))
    .previewEnvironment()
}

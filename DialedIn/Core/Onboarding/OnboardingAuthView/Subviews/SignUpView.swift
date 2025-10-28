//
//  SignInSection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI
import Foundation
import FirebaseAuth

protocol SignUpInteractor: Sendable {
    func createUser(email: String, password: String) async throws -> UserAuthInfo
    func logIn(auth: UserAuthInfo, image: PlatformImage?) async throws
    func trackEvent(event: LoggableEvent)
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
    func handleUserLoginError(_ error: Error) -> AuthErrorInfo
}

extension CoreInteractor: SignUpInteractor { }

@Observable
@MainActor
class SignUpViewModel {
    private let interactor: SignUpInteractor

    var email: String = ""
    var password: String = ""
    var passwordReenter: String = ""

    var emailTouched: Bool = false
    var passwordTouched: Bool = false
    var passwordReenterTouched: Bool = false

    var isLoadingAuth: Bool = false
    var isLoadingUser: Bool = false

    var showAlert: AnyAppAlert?
    var currentAuthTask: Task<Void, Never>?
    var navigationDestination: NavigationDestination?

    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif

    init(
        interactor: SignUpInteractor
    ) {
        self.interactor = interactor
    }

    func onSignUpPressed() {
        // Cancel any existing auth task to prevent race conditions
        currentAuthTask?.cancel()
        isLoadingAuth = true

        currentAuthTask = Task {
            defer {
                isLoadingAuth = false
                currentAuthTask = nil
            }

            interactor.trackEvent(event: Event.signUpStart)
            do {
                try await performAuthWithTimeout {
                    let auth = try await self.interactor.createUser(email: self.email, password: self.password)
                    await self.handleOnAuthSuccess(user: auth)
                }

                interactor.trackEvent(event: Event.signUpSuccess)
            } catch {
                // Only show error if task wasn't cancelled
                if !Task.isCancelled {
                    handleAuthError(error, operation: "sign up") {
                        Task { @MainActor in
                            self.onSignUpPressed()
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
            isLoadingUser = true
            defer {
                isLoadingUser = false
                currentAuthTask = nil
            }

            interactor.trackEvent(event: Event.userLoginStart)
            do {
                try await performAuthWithTimeout {
                    try await self.interactor.logIn(auth: user, image: nil)
                }
                interactor.trackEvent(event: Event.userLoginSuccess)

                // Only navigate if task wasn't cancelled
                if !Task.isCancelled {
                    navigationDestination = .emailVerification
                }
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
        let errorInfo = interactor.handleAuthError(error, operation: operation)

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
        let errorInfo = interactor.handleUserLoginError(error)

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

    var emailValidationError: String? {
        let trimmed = (email).trimmingCharacters(in: .whitespacesAndNewlines)
        guard emailTouched else { return nil }
        if trimmed.isEmpty { return "Email is required" }
        if !isValidEmail(trimmed) { return "Enter a valid email" }
        return nil
    }

    var passwordValidationError: String? {
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

    var passwordReenterValidationError: String? {
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

struct SignUpView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: SignUpViewModel

    enum NavigationDestination {
        case emailVerification
    }
    
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
        .sheet(isPresented: $viewModel.showDebugView) {
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
            get: { viewModel.navigationDestination == .emailVerification },
            set: { if !$0 { viewModel.navigationDestination = nil } }
        )) {
            EmailVerificationView(viewModel: EmailVerificationViewModel(interactor: CoreInteractor(container: container)))
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: $viewModel.isLoadingUser) {
            ProgressView()
                .tint(.white)
        }
        .onDisappear {
            // Clean up any ongoing tasks and reset loading states
            viewModel.currentAuthTask?.cancel()
            viewModel.currentAuthTask = nil
            viewModel.isLoadingAuth = false
            viewModel.isLoadingUser = false
        }
    }
    
    private var emailSection: some View {
        Section {
            TextField("Please enter your email",
                      text: $viewModel.email
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .onChange(of: viewModel.email) { _, _ in
                viewModel.emailTouched = true
            }
            if let error = viewModel.emailValidationError {
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
                text: $viewModel.password
            )
            .textContentType(.newPassword)
            .onChange(of: viewModel.password) { _, _ in
                viewModel.passwordTouched = true
            }
            
            if let error = viewModel.passwordValidationError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.red)
            }
            SecureField("Please re-enter your password",
                        text: $viewModel.passwordReenter
            )
            .textContentType(.newPassword)
            .onChange(of: viewModel.passwordReenter) { _, _ in viewModel.passwordReenterTouched = true }
            if let error = viewModel.passwordReenterValidationError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.red)
            }
        } header: {
            Text("Password")
        }
    }
    
    // MARK: - Auth Functions
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.onSignUpPressed()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview("Sign Up") {
    NavigationStack {
        SignUpView(viewModel: SignUpViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
    }
    .previewEnvironment()
}

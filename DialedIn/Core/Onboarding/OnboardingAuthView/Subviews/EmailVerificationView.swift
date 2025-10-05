//
//  EmailVerificationView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct EmailVerificationView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    @State private var isLoadingCheck: Bool = false
    @State private var isLoadingResend: Bool = false
    @State private var currentAuthTask: Task<Void, Never>?
    @State private var currentPollingTask: Task<Void, Never>?

    @State private var navigationDestination: NavigationDestination?

    @State private var showAlert: AnyAppAlert?
    @State private var toastMessage: String?
    private let pollIntervalSeconds: Double = 7
    
    enum NavigationDestination {
        case subscription
    }
    
    var body: some View {
        List {
            Section {
                Text("Check your inbox and click the link we sent you to activate your account before you continue. If you don't see it, check your spam folder.")
                    .multilineTextAlignment(.leading)
                    .removeListRowFormatting()
                    .padding(.horizontal)
                    .foregroundStyle(Color.secondary)
            } header: {
                Text("Verify your email")
            }
        }
        .navigationTitle("Email Verification")
        .showCustomAlert(alert: $showAlert)
        .navigationDestination(isPresented: Binding(
            get: { navigationDestination == .subscription },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            OnboardingSubscriptionView()
        }
        .showModal(showModal: Binding(
            get: { isLoadingCheck || isLoadingResend },
            set: { _ in }
        )) {
            ProgressView()
                .tint(.white)
        }
        .overlay(alignment: .bottom) {
            if let toastMessage {
                Text(toastMessage)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.85))
                    )
                    .padding(.bottom, 80)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.smooth, value: toastMessage)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Capsule()
                    .frame(height: AuthConstants.buttonHeight)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle((!isLoadingCheck && !isLoadingResend) ? Color.accent : Color.gray.opacity(0.3))
                    .padding(.horizontal)
                    .overlay(alignment: .center) {
                        if !isLoadingCheck && !isLoadingResend {
                            Text("Done")
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 32)
                        } else {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .allowsHitTesting(!isLoadingCheck && !isLoadingResend)
                    .anyButton(.press) {
                        onDonePressed()
                    }
                Text("Resend Email")
                    .foregroundStyle(Color.secondary)
                    .padding(.top)
                    .allowsHitTesting(!isLoadingCheck && !isLoadingResend)
                    .anyButton(.press) {
                        onResendPressed()
                    }
            }
        }
        .onFirstTask {
            startSendVerificationEmail(isInitial: true)
            startPolling()
        }
        .onDisappear {
            // Clean up any ongoing tasks and reset loading states
            currentAuthTask?.cancel()
            currentAuthTask = nil
            currentPollingTask?.cancel()
            currentPollingTask = nil
            isLoadingCheck = false
            isLoadingResend = false
        }
    }
    
    // MARK: - Actions
    
    private func startSendVerificationEmail(isInitial: Bool = false) {
        // If user is not signed in, show recovery alert
        guard authManager.auth != nil else {
            showNotSignedInAlert()
            return
        }
        // Prevent overlapping operations
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            isLoadingResend = true
            defer {
                isLoadingResend = false
                currentAuthTask = nil
            }
            
            logManager.trackEvent(event: Event.sendEmailVerificationStart)
            do {
                try await performAuthWithTimeout {
                    try await authManager.sendVerificationEmail()
                }
                logManager.trackEvent(event: Event.sendEmailVerificationSuccess)
                let message = isInitial ? "Verification email sent" : "Verification email resent"
                showToast(message)
            } catch {
                if !Task.isCancelled {
                    logManager.trackEvent(event: Event.sendEmailVerificationFail(error: error))
                    let errorInfo = AuthErrorHandler.handle(error, operation: "send verification email", logManager: logManager)
                    showAlert = AnyAppAlert(
                        title: errorInfo.title,
                        subtitle: errorInfo.message,
                        buttons: {
                            AnyView(
                                HStack {
                                    Button("Cancel") { }
                                    if errorInfo.isRetryable {
                                        Button("Try Again") {
                                            startSendVerificationEmail(isInitial: isInitial)
                                        }
                                    }
                                }
                            )
                        }
                    )
                }
            }
        }
    }
    
    private func onDonePressed() {
        // If user is not signed in, show recovery alert
        guard authManager.auth != nil else {
            showNotSignedInAlert()
            return
        }
        // Prevent overlapping operations
        currentAuthTask?.cancel()
        
        currentAuthTask = Task {
            isLoadingCheck = true
            defer {
                isLoadingCheck = false
                currentAuthTask = nil
            }
            
            logManager.trackEvent(event: Event.checkEmailVerificationStart)
            do {
                let isVerified: Bool = try await performAuthWithTimeout {
                    return try await authManager.checkEmailVerification()
                }
                logManager.trackEvent(event: Event.checkEmailVerificationSuccess(isVerified: isVerified))
                if isVerified && !Task.isCancelled {
                    navigationDestination = .subscription
                    // Stop polling on success
                    currentPollingTask?.cancel()
                    currentPollingTask = nil
                } else if !Task.isCancelled {
                    // Show alert if not verified
                    showAlert = AnyAppAlert(
                        title: "Email not verified yet",
                        subtitle: "Please click the verification link we sent to your email. You can resend the email or try checking again.",
                        buttons: {
                            AnyView(
                                VStack {
                                    Button("Resend Email") {
                                        onResendPressed()
                                    }
                                    Button("Check Again") {
                                        onDonePressed()
                                    }
                                    Button("Cancel") { }
                                }
                            )
                        }
                    )
                }
            } catch {
                if !Task.isCancelled {
                    logManager.trackEvent(event: Event.checkEmailVerificationFail(error: error))
                    let errorInfo = AuthErrorHandler.handle(error, operation: "check email verification", logManager: logManager)
                    showAlert = AnyAppAlert(
                        title: errorInfo.title,
                        subtitle: errorInfo.message,
                        buttons: {
                            AnyView(
                                HStack {
                                    Button("Cancel") { }
                                    if errorInfo.isRetryable {
                                        Button("Try Again") {
                                            onDonePressed()
                                        }
                                    }
                                }
                            )
                        }
                    )
                }
            }
        }
    }
    
    private func onResendPressed() {
        startSendVerificationEmail(isInitial: false)
    }
    
    // MARK: - Timeout Helper
    
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

    // MARK: - Alerts
    
    private func showNotSignedInAlert() {
        showAlert = AnyAppAlert(
            title: "You're not signed in",
            subtitle: "Please sign in again to continue email verification.",
            buttons: {
                AnyView(
                    HStack {
                        Button("Cancel") { }
                        Button("Go to Sign In") {
                            dismiss()
                        }
                    }
                )
            }
        )
    }

    // MARK: - Polling & Toast
    
    private func startPolling() {
        // Avoid multiple polling tasks
        currentPollingTask?.cancel()
        currentPollingTask = Task {
            while !Task.isCancelled {
                // Don't poll while user actions are running
                if !isLoadingCheck && !isLoadingResend {
                    do {
                        let isVerified: Bool = try await performAuthWithTimeout {
                            try await authManager.checkEmailVerification()
                        }
                        if isVerified && !Task.isCancelled {
                            navigationDestination = .subscription
                            break
                        }
                    } catch {
                        // Ignore transient polling errors
                    }
                }
                do {
                    try await Task.sleep(for: .seconds(pollIntervalSeconds))
                } catch { break }
            }
            // Clear reference when done
            currentPollingTask = nil
        }
    }
    
    private func showToast(_ message: String) {
        withAnimation {
            toastMessage = message
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation {
                        if toastMessage == message {
                            toastMessage = nil
                        }
                    }
                }
            }
        }
    }
    
    enum Event: LoggableEvent {
        case sendEmailVerificationStart
        case sendEmailVerificationSuccess
        case sendEmailVerificationFail(error: Error)
        case checkEmailVerificationStart
        case checkEmailVerificationSuccess(isVerified: Bool)
        case checkEmailVerificationFail(error: Error)
        
        var eventName: String {
            switch self {
            case .sendEmailVerificationStart:    return "Onboarding_EmailVerification_SendStart"
            case .sendEmailVerificationSuccess:  return "Onboarding_EmailVerification_SendSuccess"
            case .sendEmailVerificationFail:     return "Onboarding_EmailVerification_SendFail"
            case .checkEmailVerificationStart:   return "Onboarding_EmailVerification_CheckStart"
            case .checkEmailVerificationSuccess: return "Onboarding_EmailVerification_CheckSuccess"
            case .checkEmailVerificationFail:    return "Onboarding_EmailVerification_CheckFail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .sendEmailVerificationFail(error: let error), .checkEmailVerificationFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .sendEmailVerificationFail, .checkEmailVerificationFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

// MARK: - Previews

#Preview("Default") {
    NavigationStack {
        EmailVerificationView()
    }
    .previewEnvironment()
}

#Preview("Initial Send - Success") {
    NavigationStack {
        EmailVerificationView()
    }
    .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false), delay: 0, showError: false, isEmailVerified: false)))
    .previewEnvironment()
}

#Preview("Initial Send - Slow") {
    NavigationStack {
        EmailVerificationView()
    }
    .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false), delay: 3, showError: false, isEmailVerified: false)))
    .previewEnvironment()
}

#Preview("Initial Send - Failure") {
    NavigationStack {
        EmailVerificationView()
    }
    .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false), delay: 0, showError: true, isEmailVerified: false)))
    .previewEnvironment()
}

#Preview("Check - Not Verified") {
    NavigationStack {
        EmailVerificationView()
    }
    .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false), delay: 0, showError: false, isEmailVerified: false)))
    .previewEnvironment()
}

#Preview("Check - Verified") {
    NavigationStack {
        EmailVerificationView()
    }
    .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false), delay: 0, showError: false, isEmailVerified: true)))
    .previewEnvironment()
}

#Preview("No Current User - Error") {
    NavigationStack {
        EmailVerificationView()
    }
    .environment(AuthManager(service: MockAuthService(user: nil, delay: 0, showError: false, isEmailVerified: false)))
    .previewEnvironment()
}

//
//  SignInSection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI
import Foundation

struct EmailAuthSection: View {
    @Environment(AuthManager.self) private var authManager

    let mode: EmailAuthSectionMode
    @State private var email: String?
    @State private var password: String?
    @State private var passwordReenter: String?
    @State private var emailTouched: Bool = false
    @State private var passwordTouched: Bool = false
    @State private var passwordReenterTouched: Bool = false

    var body: some View {
        List {
            Section {
                TextField("Please enter your email",
                          text: Binding(
                            get: { email ?? "" },
                            set: { newValue in
                                email = newValue.isEmpty ? nil : newValue
                            }
                          )
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

            Section {
                SecureField("Please enter your password",
                            text: Binding(
                                get: { password ?? "" },
                                set: { newValue in
                                    password = newValue.isEmpty ? nil : newValue
                                }
                            )
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
                                text: Binding(
                                    get: { passwordReenter ?? "" },
                                    set: { newValue in
                                        passwordReenter = newValue.isEmpty ? nil : newValue
                                    }
                                )
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
        .navigationTitle(mode.description)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            Capsule()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .foregroundStyle(canSubmit ? Color.accent : Color.gray.opacity(0.3))
                .padding(.horizontal)
                .overlay(alignment: .center) {
                    Text(mode.description)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 32)
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

    // MARK: - Validation

    private var emailValidationError: String? {
        let trimmed = (email ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard emailTouched else { return nil }
        if trimmed.isEmpty { return "Email is required" }
        if !isValidEmail(trimmed) { return "Enter a valid email" }
        return nil
    }

    private var passwordValidationError: String? {
        let value = password ?? ""
        guard passwordTouched else { return nil }
        if value.isEmpty { return "Password is required" }

        // Enforce strong policy only for sign up (no force-upgrade on sign-in)
        if mode == .signUp {
            if value.count < 8 { return "Password must be at least 8 characters" }
            if value.count > 4096 { return "Password must be at most 4096 characters" }

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
        let value = passwordReenter ?? ""
        guard passwordReenterTouched else { return nil }
        if value.isEmpty { return "Please re-enter your password" }
        if value != (password ?? "") { return "Passwords do not match" }
        return nil
    }

    private var canSubmit: Bool {
        let emailOk = emailValidationError == nil && !(email ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let passwordOk = passwordValidationError == nil && !(password ?? "").isEmpty
        switch mode {
        case .signIn:
            return emailOk && passwordOk
        case .signUp:
            let confirmOk = passwordReenterValidationError == nil && !(passwordReenter ?? "").isEmpty
            return emailOk && passwordOk && confirmOk
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", pattern)
        return predicate.evaluate(with: email)
    }
}

#Preview("Sign In") {
    NavigationStack {
        EmailAuthSection(mode: .signIn)
    }
    .previewEnvironment()
}

#Preview("Sign Up") {
    NavigationStack {
        EmailAuthSection(mode: .signUp)
    }
    .previewEnvironment()
}

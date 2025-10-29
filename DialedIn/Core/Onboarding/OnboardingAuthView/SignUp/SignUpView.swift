//
//  SignInSection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI

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

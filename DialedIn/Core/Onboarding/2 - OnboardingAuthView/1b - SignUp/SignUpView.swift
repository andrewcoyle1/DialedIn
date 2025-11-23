//
//  SignInSection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI
import CustomRouting

struct SignUpView: View {

    @State var viewModel: SignUpViewModel

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
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: $viewModel.isLoadingUser) {
            ProgressView()
                .tint(.white)
        }
        .onDisappear {
            viewModel.cleanup()
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
                viewModel.onDevSettingsPressed()
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
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingSignUpView(router: router)
    }
    .previewEnvironment()
}

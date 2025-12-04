//
//  SignInSection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct SignUpView: View {

    @State var presenter: SignUpPresenter

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
        .showModal(showModal: $presenter.isLoadingUser) {
            ProgressView()
                .tint(.white)
        }
        .onDisappear {
            presenter.cleanup()
        }
    }
    
    private var emailSection: some View {
        Section {
            TextField("Please enter your email",
                      text: $presenter.email
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .onChange(of: presenter.email) { _, _ in
                presenter.emailTouched = true
            }
            if let error = presenter.emailValidationError {
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
                text: $presenter.password
            )
            .textContentType(.newPassword)
            .onChange(of: presenter.password) { _, _ in
                presenter.passwordTouched = true
            }
            
            if let error = presenter.passwordValidationError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.red)
            }
            SecureField("Please re-enter your password",
                        text: $presenter.passwordReenter
            )
            .textContentType(.newPassword)
            .onChange(of: presenter.passwordReenter) { _, _ in presenter.passwordReenterTouched = true }
            if let error = presenter.passwordReenterValidationError {
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
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.onSignUpPressed()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview("Sign Up") {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingSignUpView(router: router)
    }
    .previewEnvironment()
}

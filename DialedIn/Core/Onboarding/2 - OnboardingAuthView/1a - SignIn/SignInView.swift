//
//  SignInView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI
import CustomRouting

struct SignInView: View {

    @State var presenter: SignInPresenter

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
        // .modifier(NavigationDestinationsModifier(navigationDestination: $presenter.navigationDestination))
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
            .textContentType(.password)
            .onChange(of: presenter.password) { _, _ in
                presenter.passwordTouched = true
            }
            
            if let error = presenter.passwordValidationError {
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
                presenter.onSignInPressed()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview("Sign In") {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingSignInView(router: router)
    }
    .previewEnvironment()
}

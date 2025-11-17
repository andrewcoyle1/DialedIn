//
//  SignInView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI

struct SignInViewDelegate {
    var path: Binding<[OnboardingPathOption]>
}

struct SignInView: View {
    @Environment(CoreBuilder.self) private var builder

    @State var viewModel: SignInViewModel

    var delegate: SignInViewDelegate

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
        // .modifier(NavigationDestinationsModifier(navigationDestination: $viewModel.navigationDestination))
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: $viewModel.isLoadingUser) {
            ProgressView()
                .tint(.white)
        }
        .onDisappear {
            viewModel.cleanup()
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            builder.devSettingsView()
        }
        #endif
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
            .textContentType(.password)
            .onChange(of: viewModel.password) { _, _ in
                viewModel.passwordTouched = true
            }
            
            if let error = viewModel.passwordValidationError {
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
                viewModel.onSignInPressed(path: delegate.path)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview("Sign In") {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.onboardingSignInView(delegate: SignInViewDelegate(path: $path))
    }
    .previewEnvironment()
}

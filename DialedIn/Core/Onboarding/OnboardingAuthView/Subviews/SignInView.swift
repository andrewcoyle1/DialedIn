//
//  SignInView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI

struct SignInView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: SignInViewModel

    @Environment(AppState.self) private var appState
    
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
        .modifier(NavigationDestinationsModifier(navigationDestination: $viewModel.navigationDestination))
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
                viewModel.onSignInPressed()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

// MARK: - Navigation Destinations Modifier

struct NavigationDestinationsModifier: ViewModifier {
    @Binding var navigationDestination: NavigationDestination?
    @Environment(DependencyContainer.self) private var container

    // swiftlint:disable:next function_body_length
    func body(content: Content) -> some View {
        content
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .emailVerification },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                EmailVerificationView(
                    viewModel: EmailVerificationViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .subscription },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                OnboardingSubscriptionView(
                    viewModel: OnboardingSubscriptionViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .completeAccountSetup },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                OnboardingCompleteAccountSetupView(
                    viewModel: OnboardingCompleteAccountSetupViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .healthDisclaimer },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                OnboardingHealthDisclaimerView(
                    viewModel: OnboardingHealthDisclaimerViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .goalSetting },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                OnboardingGoalSettingView(
                    viewModel: OnboardingGoalSettingViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .customiseProgram },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                OnboardingPreferredDietView(
                    viewModel: OnboardingPreferredDietViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
            .navigationDestination(isPresented: Binding(
                get: { navigationDestination == .diet },
                set: { if !$0 { navigationDestination = nil } }
            )) {
                OnboardingDietPlanView(
                    viewModel: OnboardingDietPlanViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
    }
}

#Preview("Sign In") {
    NavigationStack {
        SignInView(viewModel: SignInViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
    }
    .previewEnvironment()
}

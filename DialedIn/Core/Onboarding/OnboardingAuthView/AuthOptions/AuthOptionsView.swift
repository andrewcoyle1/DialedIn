//
//  AuthOptionsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI

struct AuthOptionsView: View {
    @Environment(DependencyContainer.self) private var container

    @State var viewModel: AuthOptionsViewModel
    @Binding var path: [OnboardingPathOption]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            imageSection
            Group {
                SignInWithAppleButtonView { viewModel.onSignInApplePressed(path: $path) }
                SignInWithGoogleButtonView { viewModel.onSignInGooglePressed(path: $path) }
                signUpButtonSection
                signInButtonSection
            }
            .padding(.horizontal)
        }
        .allowsHitTesting(!viewModel.isLoading)
        .background {
            Color(colorScheme.backgroundPrimary)
                .ignoresSafeArea()
        }
        #if DEBUG || MOCK
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.showDebugView = true
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        #endif
        .showCustomAlert(alert: $viewModel.showAlert)
        .safeAreaInset(edge: .bottom) {
            tsAndCsSection
                .padding(.horizontal)
        }
        .showModal(showModal: $viewModel.isLoading) {
            ProgressView()
                .tint(.white)
        }
        .onDisappear {
            viewModel.cleanUp()
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

    private var imageSection: some View {
        ImageLoaderView()
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                Text("DialedIn")
                    .font(.system(size: 64))
                    .fontDesign(.default)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.white)
                    .opacity(0.8)
                    .padding()
            }
    }

    private var signUpButtonSection: some View {
        Button {
            viewModel.signUpPressed(path: $path)
        } label: {
            HStack {
                Text("Sign Up With Email")
                    .font(.system(size: 21))
            }
            .frame(maxWidth: .infinity)
            .frame(height: AuthConstants.buttonHeight/1.5)
        }
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: 408)
    }

    private var signInButtonSection: some View {
        Button {
            viewModel.signInPressed(path: $path)
        } label: {
            HStack {
                Text("Sign In With Email")
                    .font(.system(size: 21))
            }
            .frame(maxWidth: .infinity)
            .frame(height: AuthConstants.buttonHeight/1.5)
        }
        .buttonStyle(.bordered)
        .frame(maxWidth: 408)
    }

    private var tsAndCsSection: some View {
        Text("By continuing, you agree to our [Terms of Service](Constants.termsofServiceURL) and [Privacy Policy](Constants.privacyPolicyURL)")
            .font(.caption)
            .foregroundStyle(Color.secondary)
            .padding(.top)
            .frame(maxWidth: 408)

    }
}

// MARK: - Constants and Error Types
// Note: AuthConstants and AuthTimeoutError are now defined in AuthErrorHandler.swift

#Preview("Functioning Auth") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        AuthOptionsView(
            viewModel: AuthOptionsViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}

#Preview("Slow Auth") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        AuthOptionsView(
            viewModel: AuthOptionsViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}

#Preview("Failing Auth") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        AuthOptionsView(
            viewModel: AuthOptionsViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}

#Preview("Slow Login") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        AuthOptionsView(
            viewModel: AuthOptionsViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}

#Preview("Failing Login") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        AuthOptionsView(
            viewModel: AuthOptionsViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}

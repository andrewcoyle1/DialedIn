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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            imageSection
            Group {
                SignInWithAppleButtonView { viewModel.onSignInApplePressed() }
                SignInWithGoogleButtonView { viewModel.onSignInGooglePressed() }
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
        .modifier(NavigationDestinationsModifier(navigationDestination: $viewModel.navigationDestination))
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
            // Clean up any ongoing tasks and reset loading states
            
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
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
        NavigationLink {
            SignUpView()
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
        NavigationLink {
            SignInView()
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
    NavigationStack {
        AuthOptionsView(viewModel: AuthOptionsViewModel(container: DevPreview.shared.container))
    }
    .previewEnvironment()
}

#Preview("Slow Auth") {
    NavigationStack {
        AuthOptionsView(viewModel: AuthOptionsViewModel(container: DevPreview.shared.container))
    }
    .previewEnvironment()
}

#Preview("Failing Auth") {
    NavigationStack {
        AuthOptionsView(viewModel: AuthOptionsViewModel(container: DevPreview.shared.container))
    }
    .previewEnvironment()
}

#Preview("Slow Login") {
    NavigationStack {
        AuthOptionsView(viewModel: AuthOptionsViewModel(container: DevPreview.shared.container))
    }
    .previewEnvironment()
}

#Preview("Failing Login") {
    NavigationStack {
        AuthOptionsView(viewModel: AuthOptionsViewModel(container: DevPreview.shared.container))
    }
    .previewEnvironment()
}

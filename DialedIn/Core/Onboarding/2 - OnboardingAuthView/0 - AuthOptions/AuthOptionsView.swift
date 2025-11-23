//
//  AuthOptionsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI
import CustomRouting

struct AuthOptionsView: View {

    @Environment(\.colorScheme) private var colorScheme

    @State var viewModel: AuthOptionsViewModel

    var body: some View {
        VStack {
            imageSection
            Group {
                SignInWithAppleButtonView { viewModel.onSignInApplePressed() }
                SignInWithGoogleButtonView { viewModel.onSignInGooglePressed() }
                signUpButtonSection
                signInButtonSection
                tsAndCsSection
            }
            .padding(.horizontal)
        }
        .background {
            Color(colorScheme.backgroundPrimary)
                .ignoresSafeArea()
        }
        .allowsHitTesting(!viewModel.isLoading)
        .navigationBarBackButtonHidden(true)
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: $viewModel.isLoading) {
            ProgressView()
                .tint(.white)
        }
        .onDisappear {
            viewModel.cleanUp()
        }
    }

    #if DEBUG || MOCK
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
    }
    #endif

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
            viewModel.signUpPressed()
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
            viewModel.signInPressed()
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
    let builder = CoreBuilder(container: DevPreview.shared.container)
    
    RouterView { router in
        builder.onboardingAuthOptionsView(router: router)
    }
    .previewEnvironment()
}

#Preview("Slow Auth") {
    let builder = CoreBuilder(container: DevPreview.shared.container)

    RouterView { router in
        builder.onboardingAuthOptionsView(router: router)
    }
    .previewEnvironment()
}

#Preview("Failing Auth") {
    let builder = CoreBuilder(container: DevPreview.shared.container)

    RouterView { router in
        builder.onboardingAuthOptionsView(router: router)
    }
    .previewEnvironment()
}

#Preview("Slow Login") {
    let builder = CoreBuilder(container: DevPreview.shared.container)

    RouterView { router in
        builder.onboardingAuthOptionsView(router: router)
    }
    .previewEnvironment()
}

#Preview("Failing Login") {
    let builder = CoreBuilder(container: DevPreview.shared.container)

    RouterView { router in
        builder.onboardingAuthOptionsView(router: router)
    }
    .previewEnvironment()
}

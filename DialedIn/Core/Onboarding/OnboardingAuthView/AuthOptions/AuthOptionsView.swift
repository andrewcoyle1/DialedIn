//
//  AuthOptionsSection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI

struct AuthOptionsView: View {
    
    @State var viewModel: AuthOptionsViewModel
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack {
            imageSection
            SignInWithAppleButtonView { viewModel.onSignInApplePressed() }
            SignInWithGoogleButtonView { viewModel.onSignInGooglePressed() }
            signUpButtonSection
            signInButtonSection
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
            DevSettingsView()
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
        .padding(.horizontal)
        .frame(maxWidth: 440)
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
        .padding(.horizontal)
        .frame(maxWidth: 440)
    }

    private var tsAndCsSection: some View {
        Text("By continuing, you agree to our [Terms of Service](Constants.termsofServiceURL) and [Privacy Policy](Constants.privacyPolicyURL)")
            .font(.caption)
            .foregroundStyle(Color.secondary)
            .padding(.horizontal)
            .padding(.top)
            .frame(maxWidth: 440)

    }
}

// MARK: - Constants and Error Types
// Note: AuthConstants and AuthTimeoutError are now defined in AuthErrorHandler.swift

#Preview("Functioning Auth") {
    @Previewable @State var userAuth: UserAuthInfo?
    @Previewable @State var isNewUser: Bool = false
    let logManager = LogManager(services: [ConsoleService(printParameters: false)])
    let authManager = AuthManager(service: MockAuthService(), logManager: logManager)
    let userManager = UserManager(services: MockUserServices(), logManager: logManager)
    NavigationStack {
        AuthOptionsView(viewModel: AuthOptionsViewModel(authManager: authManager, userManager: userManager, logManager: logManager))
    }
    .previewEnvironment()
}

#Preview("Slow Auth") {
    let logManager = LogManager(services: [ConsoleService(printParameters: false)])
    let authManager = AuthManager(service: MockAuthService(delay: 3), logManager: logManager)
    let userManager = UserManager(services: MockUserServices(), logManager: logManager)
    NavigationStack {
        AuthOptionsView(viewModel: AuthOptionsViewModel(authManager: authManager, userManager: userManager, logManager: logManager))
    }
    .previewEnvironment()
}

#Preview("Failing Auth") {
    let logManager = LogManager(services: [ConsoleService(printParameters: false)])
    let authManager = AuthManager(service: MockAuthService(user: nil, showError: true), logManager: logManager)
    let userManager = UserManager(services: MockUserServices(), logManager: logManager)
    NavigationStack {
        AuthOptionsView(viewModel: AuthOptionsViewModel(authManager: authManager, userManager: userManager, logManager: logManager))
    }
    .previewEnvironment()
}

#Preview("Slow Login") {
    let logManager = LogManager(services: [ConsoleService(printParameters: true)])
    let authManager = AuthManager(service: MockAuthService(user: nil), logManager: logManager)
    let userManager = UserManager(services: MockUserServices(user: nil, delay: 3), logManager: logManager)
    NavigationStack {
        AuthOptionsView(viewModel: AuthOptionsViewModel(authManager: authManager, userManager: userManager, logManager: logManager))
    }
    .previewEnvironment()
}

#Preview("Failing Login") {
    let logManager = LogManager(services: [ConsoleService(printParameters: false)])
    let authManager = AuthManager(service: MockAuthService(user: nil, showError: true), logManager: logManager)
    let userManager = UserManager(services: MockUserServices(user: nil, showError: true), logManager: logManager)
    NavigationStack {
        AuthOptionsView(viewModel: AuthOptionsViewModel(authManager: authManager, userManager: userManager, logManager: logManager))
    }
    .previewEnvironment()
}

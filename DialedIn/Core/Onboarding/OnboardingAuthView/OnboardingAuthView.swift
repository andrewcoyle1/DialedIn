//
//  OnboardingAuthView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

struct OnboardingAuthView: View {
    @Environment(PushManager.self) private var pushManager
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    @State private var navigateToCreateProfile: Bool = false
    @State private var navigateToOnboardingNotifications: Bool = false
    @State var showAlert: AnyAppAlert?

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    var body: some View {
        List {
            whySection
            whyNotSection
            VStack(alignment: .center) {
                appleSignInSection
                googleSignInSection
                    .padding(.horizontal)
            }
            tsAndCsSection
        }
        .navigationTitle("Authentication")
        .navigationBarTitleDisplayMode(.large)
        #if !DEBUG && !MOCK
        .navigationBarBackButtonHidden(true)
        #else
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showDebugView = true
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
        #endif
        .screenAppearAnalytics(name: "OnboardingAuth")
        .navigationDestination(isPresented: $navigateToCreateProfile) {
            OnboardingCreateProfileView()
        }
        .showCustomAlert(alert: $showAlert)
        .task {
            await handlePushNotificationsPermission()
        }
        .safeAreaInset(edge: .bottom) {
            VStack {

                NavigationLink {
                    if navigateToOnboardingNotifications {
                        OnboardingNotificationsView()
                    } else {
                        OnboardingCompletedView()
                    }
                } label: {
                    Text("Not now")
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom)
            }
        }
    }
    
    private var whySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Why Create an Account?")
                    .font(.headline)
                    .padding(.bottom, 2)
                Text("• Securely back up your workouts and progress to the cloud.")
                Text("• Access your data across all devices.")
                Text("• Unlock personalized features and participate in social challenges.")
                Text("• Your privacy is protected—data is encrypted and never shared without consent.")
            }
            .font(.system(size: 16))
            .padding(.vertical, 4)
        } header: {
            Text("Why Sign Up?")
        }
    }
    
    private var whyNotSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("If You Skip")
                    .font(.headline)
                    .padding(.bottom, 2)
                Text("• You can still explore the app, but your data stays only on this device.")
                Text("• Progress may be lost if you delete the app or switch devices.")
                Text("• Some features, like syncing and social, will be unavailable.")
            }
            .font(.system(size: 16))
            .padding(.vertical, 4)
        } header: {
            Text("Guest Mode Limitations")
        }
    }

    private var appleSignInSection: some View {
        SignInWithAppleButtonView(type: .signUp, style: .black, cornerRadius: 28)
            .frame(height: 56)
            .anyButton(.press) {
                onSignInApplePressed()
            }
            .padding(.horizontal)
            .removeListRowFormatting()
    }

    private var googleSignInSection: some View {
        SignInWithGoogleButtonView(style: .light, scheme: .signUpWithGoogle) { onSignInGooglePressed() }
        .removeListRowFormatting()
    }

    private var tsAndCsSection: some View {
        Text("By continuing, you agree to our Terms of Service and Privacy Policy")
            .removeListRowFormatting()
    }

    private func handlePushNotificationsPermission() async {
        navigateToOnboardingNotifications = await pushManager.canRequestAuthorisation()
    }

    private func onSignInApplePressed() {
        
        Task {
            do {
                let result = try await authManager.signInApple()
                logManager.trackEvent(eventName: "OnboardingAuth_AppleAuth_Success")
                
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                logManager.trackEvent(eventName: "OnboardingAuth_AppleAuth_Login_Success")
                
                // Navigate to create profile on successful sign-in
                navigateToCreateProfile = true
            } catch {
                logManager.trackEvent(eventName: "OnboardingAuth_AppleAuth_Fail", parameters: error.eventParameters, type: .severe)
                
                showAlert = buildAlert()
            }
        }
    }
    
    private func buildAlert() -> AnyAppAlert {
        AnyAppAlert(
            title: "Error",
            subtitle: "Failed to sign in with Apple. Please try again.",
            buttons: {
                AnyView(
                    HStack {
                        NavigationLink {
                            OnboardingNotificationsView()
                        } label: {
                            Text("Skip for now")
                        }
                        
                        Button {
                            // Dismiss the alert and retry sign in
                            showAlert = nil
                            // onSignInApplePressed()
                        } label: {
                            Text("Try again")
                                .foregroundStyle(.brown)
                        }
                    }
                )
            })
    }
    
    private func onSignInGooglePressed() {
        Task {
            do {
                let result = try await authManager.signInGoogle()
                logManager.trackEvent(eventName: "OnboardingAuth_GoogleAuth_Success")
                
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                logManager.trackEvent(eventName: "OnboardingAuth_GoogleAuth_Login_Success")
                
                // Navigate to create profile on successful sign-in
                navigateToCreateProfile = true
            } catch {
                logManager.trackEvent(eventName: "OnboardingAuth_GoogleAuth_Fail", parameters: error.eventParameters, type: .severe)
                
                showAlert = buildAlert()
            }
        }
    }
}

#Preview("Auth Success") {
    NavigationStack {
        OnboardingAuthView()
    }
    .previewEnvironment()
}

#Preview("Slow Loading") {
    NavigationStack {
        OnboardingAuthView()
    }
    .environment(AuthManager(service: MockAuthService(delay: 3)))
    .previewEnvironment()
}

#Preview("Auth Failure") {
    NavigationStack {
        OnboardingAuthView()
    }
    .environment(AuthManager(service: MockAuthService(user: nil, showError: true)))
    .previewEnvironment()
}

#Preview("Show Error") {
    NavigationStack {
        OnboardingAuthView(
            showAlert:
                AnyAppAlert(
                    title: "Error",
                    subtitle: "Failed to sign in with Apple. Please try again.",
                    buttons: {
                        AnyView(
                            HStack {
                                NavigationLink {
                                    OnboardingNotificationsView()
                                } label: {
                                    Text("Skip for now")
                                }
                                
                                Button(role: .close) {
                                    // Dismiss the alert and retry sign in
                                    
                                } label: {
                                    Text("Try again")
                                }
                                
                            }
                            
                        )
                    }
                )
        )
    }
    .environment(AuthManager(service: MockAuthService(user: nil, showError: true)))
    .previewEnvironment()
}

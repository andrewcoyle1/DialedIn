//
//  OnboardingWelcomeView.swift
//  BrainBolt
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct OnboardingWelcomeView: View {

    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var root
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    @State var imageName: String = Constants.randomImage
    @State private var showSignInView: Bool = false

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                ImageLoaderView(urlString: imageName)
                    .ignoresSafeArea()
                titleSection
                    .padding(.top, 8)
                
                Spacer()

                policyLinks
            }
            .padding(.bottom)
            .toolbar {
                toolbarContent
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView) {
                DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
            }
            #endif
            .screenAppearAnalytics(name: "Welcome")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            NavigationLink {
                AuthOptionsView(viewModel: AuthOptionsViewModel(container: container))
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "gauge.with.needle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.accent)
            Text("Dialed")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("A better way to manage your training")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
        }
        .padding(.top, 24)
    }
    
    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsofServiceURL)!) {
                Text("Terms of Service")
            }
            
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            
            Link(destination: URL(string: Constants.privacyPolicyURL)!) {
                Text("Privacy Policy")
            }
        }
    }
}

#Preview("Functioning") {
    OnboardingWelcomeView()
        .previewEnvironment()
}

#Preview("Slow Loading") {
    OnboardingWelcomeView()
        .environment(AuthManager(service: MockAuthService(delay: 3)))
        .previewEnvironment()
}

#Preview("Auth Failure") {
    OnboardingWelcomeView()
        .environment(AuthManager(service: MockAuthService(user: nil, showError: true)))
        .previewEnvironment()
}

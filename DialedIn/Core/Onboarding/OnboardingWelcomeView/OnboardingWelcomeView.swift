//
//  OnboardingWelcomeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct OnboardingWelcomeView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var root
    @State var viewModel: OnboardingWelcomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack(spacing: 8) {
                ImageLoaderView(urlString: viewModel.imageName)
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
            .sheet(isPresented: $viewModel.showDebugView) {
                DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
            }
            #endif
            .screenAppearAnalytics(name: "Welcome")
            .navigationDestinationOnboardingModule(path: $viewModel.path)
        }
    }
    
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
                viewModel.navToAppropriateView()
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
    OnboardingWelcomeView(
        viewModel: OnboardingWelcomeViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        )
    )
    .previewEnvironment()
}

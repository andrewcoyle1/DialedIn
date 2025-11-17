//
//  OnboardingHealthDisclaimerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingHealthDisclaimerViewDelegate {
    var path: Binding<[OnboardingPathOption]>
}
struct OnboardingHealthDisclaimerView: View {
    @Environment(CoreBuilder.self) private var builder

    @State var viewModel: OnboardingHealthDisclaimerViewModel

    var delegate: OnboardingHealthDisclaimerViewDelegate

    var body: some View {
        List {
            disclaimerSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Notice")
        .safeAreaInset(edge: .bottom) {
            buttonSection
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: $viewModel.showModal, content: {
            confirmationModal
        })
        .showModal(showModal: $viewModel.isLoading) {
            ProgressView()
                .tint(.white)
        }
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            builder.devSettingsView()
        }
        #endif
    }
    
    private var disclaimerSection: some View {
        Section {
            Text(viewModel.disclaimerString)
        } header: {
            Text("Health Disclaimer")
        }
    }
    
    private var buttonSection: some View {
        VStack {
            Toggle(isOn: $viewModel.acceptedTerms) {
                Text("I acknowledge and accept the Terms of the Health Disclaimer")
                    .font(.callout)
            }
            Toggle(isOn: $viewModel.acceptedPrivacy) {
                Text("I acknowledge and accept the Terms of the Consumer Health Privacy Notice")
                    .font(.callout)
            }
        }
        .padding()
        .background(.bar)
    }
    
    private var confirmationModal: some View {
        CustomModalView(
            title: "Confirm and Continue",
            subtitle: """
            By continuing, you confirm that:
            • You have read and accept the Health Disclaimer.
            • You have read and accept the Consumer Health Privacy Notice.

            You understand DialedIn does not provide medical advice and is for educational use only. You can review these terms at any time in Settings.
            """,
            primaryButtonTitle: "I Agree & Continue",
            primaryButtonAction: { viewModel.onConfirmPressed(path: delegate.path) },
            secondaryButtonTitle: "Go Back",
            secondaryButtonAction: { viewModel.onCancelPressed() }
        )
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
                viewModel.onContinuePressed()
            } label: {
                Text("Continue")
                    .padding()
            }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canContinue)
        }
    }
}

#Preview("Health Disclaimer") {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.onboardingHealthDisclaimerView(
            delegate: OnboardingHealthDisclaimerViewDelegate(
                path: $path
            )
        )
    }
    .previewEnvironment()
}

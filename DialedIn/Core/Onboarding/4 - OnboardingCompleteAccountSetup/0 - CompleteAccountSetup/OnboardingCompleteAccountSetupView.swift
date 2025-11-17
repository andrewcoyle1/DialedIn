//
//  OnboardingCompleteAccountSetupView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingCompleteAccountSetupViewDelegate {
    var path: Binding<[OnboardingPathOption]>
}

struct OnboardingCompleteAccountSetupView: View {

    @Environment(CoreBuilder.self) private var builder

    @State var viewModel: OnboardingCompleteAccountSetupViewModel

    var delegate: OnboardingCompleteAccountSetupViewDelegate

    var body: some View {
        List {
            Text("Intro to complete account setup - explain why the user needs to submit their data")
        }
        .navigationTitle("Welcome")
        .navigationBarBackButtonHidden()
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            builder.devSettingsView()
        }
        #endif
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
                viewModel.handleNavigation(path: delegate.path)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack(path: $path) {
        builder.onboardingCompleteAccountSetupView(
            delegate: OnboardingCompleteAccountSetupViewDelegate(
                path: $path
            )
        )
    }
    .navigationDestinationOnboardingModule(path: $path)
    .previewEnvironment()
}

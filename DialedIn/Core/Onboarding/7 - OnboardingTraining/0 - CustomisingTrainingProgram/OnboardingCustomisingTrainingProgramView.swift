//
//  OnboardingCustomisingProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingTrainingProgramViewDelegate {
    var path: Binding<[OnboardingPathOption]>
}

struct OnboardingTrainingProgramView: View {

    @State var viewModel: OnboardingTrainingProgramViewModel

    var delegate: OnboardingTrainingProgramViewDelegate

    @ViewBuilder var devSettingsView: () -> AnyView

    var body: some View {
        List {
            trainingSection
        }
        .navigationTitle("Customise Program")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            devSettingsView()
        }
        #endif
        .showModal(showModal: $viewModel.isLoading) {
            ProgressView()
                .tint(.white)
        }
        .showCustomAlert(alert: $viewModel.showAlert)
    }
    
    private var trainingSection: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Let's set up your training program. We'll ask a few questions about your experience, schedule, and equipment to recommend the perfect program for you.")
                Text("This can always be changed later if you want to try something different.")
                    .padding(.top)
            }
            .removeListRowFormatting()
            .padding(.horizontal)
            .foregroundStyle(Color.secondary)

        } header: {
            Text("Training Program")
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
                viewModel.navigateToTrainingExperience(path: delegate.path)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        OnboardingTrainingProgramView(
            viewModel: OnboardingTrainingProgramViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ),
            delegate: OnboardingTrainingProgramViewDelegate(
                path: $path
            ),
            devSettingsView: {
                Color.red.any()
            }
        )
    }
    .previewEnvironment()
}

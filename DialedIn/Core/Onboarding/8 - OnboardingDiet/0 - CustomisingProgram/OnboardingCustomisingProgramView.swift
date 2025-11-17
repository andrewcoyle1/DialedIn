//
//  OnboardingCustomisingProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingCustomisingProgramViewDelegate {
    var path: Binding<[OnboardingPathOption]>
}

struct OnboardingCustomisingProgramView: View {

    @Environment(CoreBuilder.self) private var builder

    @State var viewModel: OnboardingCustomisingProgramViewModel

    var delegate: OnboardingCustomisingProgramViewDelegate

    var body: some View {
        List {
            trainingSection
            dietSection
        }
        .navigationTitle("Customise Program")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            builder.devSettingsView()
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
            Button {
                viewModel.navigateToTrainingExperience(path: delegate.path)
            } label: {
                HStack {
                    Text("Set Up Training Program")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
        } header: {
            Text("Training Program")
        }
    }
    
    private var dietSection: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Let's get to work creating a custom diet program tuned to your needs. This will evolve over time as we learn how your body responds to the diet and make the necessary changes. This can always be manually altered later if you would like a specific change.")
                Text("We'll start with a few questions to get you started.")
                    .padding(.top)
            }
            .removeListRowFormatting()
            .padding(.horizontal)
            .foregroundStyle(Color.secondary)
        } header: {
            Text("Diet Program")
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
                viewModel.navigateToPreferredDiet(path: delegate.path)
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
    NavigationStack {
        builder.onboardingCustomisingProgramView(
            delegate: OnboardingCustomisingProgramViewDelegate(
                path: $path
            )
        )
    }
    .previewEnvironment()
}

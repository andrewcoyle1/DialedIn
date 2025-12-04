//
//  OnboardingCustomisingProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingCustomisingProgramView: View {

    @State var presenter: OnboardingCustomisingProgramPresenter

    var body: some View {
        List {
            trainingSection
            dietSection
        }
        .navigationTitle("Customise Program")
        .toolbar {
            toolbarContent
        }
        .showModal(showModal: $presenter.isLoading) {
            ProgressView()
                .tint(.white)
        }
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
                presenter.navigateToTrainingExperience()
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
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.navigateToPreferredDiet()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingCustomisingProgramView(router: router)
    }
    .previewEnvironment()
}

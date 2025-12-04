//
//  OnboardingCustomisingProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingTrainingProgramView: View {

    @State var presenter: OnboardingTrainingProgramPresenter

    var body: some View {
        List {
            trainingSection
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

        } header: {
            Text("Training Program")
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
                presenter.navigateToTrainingExperience()
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
        builder.onboardingTrainingProgramView(router: router)
    }
    .previewEnvironment()
}

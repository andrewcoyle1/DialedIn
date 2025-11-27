//
//  OnboardingGoalSettingView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingGoalSettingView: View {

    @State var presenter: OnboardingGoalSettingPresenter

    var body: some View {
        List {
            goalSettingSection
        }
        .navigationTitle("Goal Setting")
        .navigationBarBackButtonHidden()
        .toolbar {
            toolbarContent
        }
        .showModal(showModal: $presenter.isLoading) {
            ProgressView()
                .tint(.white)
        }
    }
    
    private var goalSettingSection: some View {
        Section {
            Text("Depending on what your goal is, we will help you by generating a custom plan to help you get there. This can be changed in future, and your plan will be updated accordingly.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } header: {
            Text("Goal")
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
                presenter.navigateToOverarchingObjective()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingGoalSettingView(router: router)
    }
    .previewEnvironment()
}

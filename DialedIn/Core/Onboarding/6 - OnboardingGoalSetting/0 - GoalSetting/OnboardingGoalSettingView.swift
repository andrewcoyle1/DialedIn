//
//  OnboardingGoalSettingView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI
import SwiftfulRouting

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

extension OnbBuilder {
    func onboardingGoalSettingView(router: AnyRouter) -> some View {
        OnboardingGoalSettingView(
            presenter: OnboardingGoalSettingPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
    }
}

extension OnbRouter {
    func showOnboardingGoalSettingView() {
        router.showScreen(.push) { router in
            builder.onboardingGoalSettingView(router: router)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingGoalSettingView(router: router)
    }
    .previewEnvironment()
}

//
//  GoalSettingView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct GoalSettingView: View {

    @State var presenter: GoalSettingPresenter

    var body: some View {
        List {
            goalSettingSection
        }
        .navigationTitle("Goal Setting")
        .navigationBarBackButtonHidden()
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.onContinuePressed()
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding(.horizontal)
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
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
    }
}

extension CoreBuilder {
    func goalSettingView(router: AnyRouter) -> some View {
        GoalSettingView(
            presenter: GoalSettingPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showGoalSettingView() {
        router.showScreen(.push) { router in
            builder.goalSettingView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.goalSettingView(router: router)
    }
    
}

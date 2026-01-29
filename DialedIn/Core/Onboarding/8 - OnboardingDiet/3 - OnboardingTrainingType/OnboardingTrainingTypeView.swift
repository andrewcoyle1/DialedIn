//
//  OnboardingTrainingTypeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingTrainingTypeView: View {

    @State var presenter: OnboardingTrainingTypePresenter

    var delegate: OnboardingTrainingTypeDelegate

    var body: some View {
        List {
            ForEach(TrainingType.allCases) { type in
                Section {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(type.description)
                                .font(.headline)
                            Text(type.detailedDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: presenter.selectedTrainingType == type ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(presenter.selectedTrainingType == type ? .accent : .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { presenter.selectedTrainingType = type }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Training Focus")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
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
                presenter.navigateToCalorieDistribution(dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedTrainingType == nil)
        }
    }
}

extension OnbBuilder {
    func onboardingTrainingTypeView(router: AnyRouter, delegate: OnboardingTrainingTypeDelegate) -> some View {
        OnboardingTrainingTypeView(
            presenter: OnboardingTrainingTypePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension OnbRouter {
    func showOnboardingTrainingTypeView(delegate: OnboardingTrainingTypeDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingTypeView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingTrainingTypeView(
            router: router,
            delegate: OnboardingTrainingTypeDelegate(
                dietPlanBuilder: .trainingTypeMock
            )
        )
    }
    .previewEnvironment()
}

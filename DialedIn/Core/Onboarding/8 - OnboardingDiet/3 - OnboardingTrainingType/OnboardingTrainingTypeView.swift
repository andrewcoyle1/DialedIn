//
//  OnboardingTrainingTypeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingTrainingTypeView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: OnboardingTrainingTypePresenter

    var delegate: OnboardingTrainingTypeDelegate

    var body: some View {
        List {
            Section {
                ForEach(TrainingType.allCases) { type in
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
                    .padding()
                    .background(colorScheme.backgroundPrimary)
                    .anyButton {
                        presenter.selectedTrainingType = type
                    }
                }
                .removeListRowFormatting()
            }
        }
        .navigationTitle("Training Focus")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.navigateToCalorieDistribution(dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedTrainingType == nil)
            .padding(.horizontal)
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
    func onboardingTrainingTypeView(router: AnyRouter, delegate: OnboardingTrainingTypeDelegate) -> some View {
        OnboardingTrainingTypeView(
            presenter: OnboardingTrainingTypePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showOnboardingTrainingTypeView(delegate: OnboardingTrainingTypeDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingTypeView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingTrainingTypeView(
            router: router,
            delegate: OnboardingTrainingTypeDelegate(
                dietPlanBuilder: .trainingTypeMock
            )
        )
    }
    
}

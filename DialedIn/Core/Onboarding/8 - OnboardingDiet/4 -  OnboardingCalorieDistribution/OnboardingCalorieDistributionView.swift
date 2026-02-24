//
//  OnboardingCalorieDistributionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingCalorieDistributionView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: OnboardingCalorieDistributionPresenter

    var delegate: OnboardingCalorieDistributionDelegate

    var body: some View {
        List {
            itemSection
        }
        .navigationTitle("Calorie distribution")
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.navigateToProteinIntake(dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedCalorieDistribution == nil)
            .padding(.horizontal)
        }
    }
    
    private var itemSection: some View {
        Section {
            ForEach(CalorieDistribution.allCases) { type in
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(type.description)
                            .font(.headline)
                        Text(type.detailedDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: presenter.selectedCalorieDistribution == type ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(presenter.selectedCalorieDistribution == type ? .accent : .secondary)
                }
                .padding()
                .background(colorScheme.backgroundPrimary)
                .anyButton {
                    presenter.selectedCalorieDistribution = type
                }
            }
            .removeListRowFormatting()
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
    func onboardingCalorieDistributionView(router: AnyRouter, delegate: OnboardingCalorieDistributionDelegate) -> some View {
        OnboardingCalorieDistributionView(
            presenter: OnboardingCalorieDistributionPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showOnboardingCalorieDistributionView(delegate: OnboardingCalorieDistributionDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCalorieDistributionView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingCalorieDistributionView(
            router: router,
            delegate: OnboardingCalorieDistributionDelegate(
                dietPlanBuilder: .calorieDistributionMock
            )
        )
    }
    
}

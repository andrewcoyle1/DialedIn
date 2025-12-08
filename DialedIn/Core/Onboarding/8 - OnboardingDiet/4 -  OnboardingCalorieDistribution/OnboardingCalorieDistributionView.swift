//
//  OnboardingCalorieDistributionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingCalorieDistributionView: View {

    @State var presenter: OnboardingCalorieDistributionPresenter

    var delegate: OnboardingCalorieDistributionDelegate

    var body: some View {
        List {
            if presenter.hasTrainingPlan {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("We'll bias carbs toward your training days.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .removeListRowFormatting()
                    .padding(.horizontal)
                }
            }
            
            itemSection
        }
        .navigationTitle("Calorie distribution")
        .toolbar {
            toolbarContent
        }
    }
    
    private var itemSection: some View {
        ForEach(CalorieDistribution.allCases) { type in
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
                    Image(systemName: presenter.selectedCalorieDistribution == type ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(presenter.selectedCalorieDistribution == type ? .accent : .secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture { presenter.selectedCalorieDistribution = type }
                .padding(.vertical)
            }
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
                presenter.navigateToProteinIntake(dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedCalorieDistribution == nil)
        }
    }
}

extension OnbBuilder {
    func onboardingCalorieDistributionView(router: AnyRouter, delegate: OnboardingCalorieDistributionDelegate) -> some View {
        OnboardingCalorieDistributionView(
            presenter: OnboardingCalorieDistributionPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension OnbRouter {
    func showOnboardingCalorieDistributionView(delegate: OnboardingCalorieDistributionDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCalorieDistributionView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingCalorieDistributionView(
            router: router,
            delegate: OnboardingCalorieDistributionDelegate(
                dietPlanBuilder: .calorieDistributionMock
            )
        )
    }
    .previewEnvironment()
}

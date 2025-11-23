//
//  OnboardingCalorieDistributionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI
import CustomRouting

// swiftlint:disable:next type_name
struct OnboardingCalorieDistributionViewDelegate {
    let dietPlanBuilder: DietPlanBuilder
}

struct OnboardingCalorieDistributionView: View {

    @State var viewModel: OnboardingCalorieDistributionViewModel

    var delegate: OnboardingCalorieDistributionViewDelegate

    var body: some View {
        List {
            if viewModel.hasTrainingPlan {
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
                    Image(systemName: viewModel.selectedCalorieDistribution == type ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(viewModel.selectedCalorieDistribution == type ? .accent : .secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture { viewModel.selectedCalorieDistribution = type }
                .padding(.vertical)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navigateToProteinIntake(dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedCalorieDistribution == nil)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingCalorieDistributionView(
            router: router,
            delegate: OnboardingCalorieDistributionViewDelegate(
                dietPlanBuilder: .calorieDistributionMock
            )
        )
    }
    .previewEnvironment()
}

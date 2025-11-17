//
//  OnboardingCalorieDistributionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingCalorieDistributionViewDelegate {
    var path: Binding<[OnboardingPathOption]>
    let dietPlanBuilder: DietPlanBuilder
}
struct OnboardingCalorieDistributionView: View {
    @Environment(CoreBuilder.self) private var builder

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
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            builder.devSettingsView()
        }
        #endif
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
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navigateToProteinIntake(path: delegate.path, dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedCalorieDistribution == nil)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.onboardingCalorieDistributionView(
            delegate: OnboardingCalorieDistributionViewDelegate(
                path: $path,
                dietPlanBuilder: .calorieDistributionMock
            )
        )
    }
    .previewEnvironment()
}

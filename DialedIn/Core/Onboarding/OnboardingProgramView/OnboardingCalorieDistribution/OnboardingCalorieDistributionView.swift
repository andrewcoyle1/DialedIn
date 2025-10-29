//
//  OnboardingCalorieDistributionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingCalorieDistributionView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingCalorieDistributionViewModel

    var body: some View {
        List {
            itemSection
        }
        .navigationTitle("Calorie distribution")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(
                viewModel: DevSettingsViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
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
            NavigationLink {
                if let calorieDistribution = viewModel.selectedCalorieDistribution {
                    OnboardingProteinIntakeView(
                        viewModel: OnboardingProteinIntakeViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            preferredDiet: viewModel.preferredDiet,
                            calorieFloor: viewModel.calorieFloor,
                            trainingType: viewModel.trainingType,
                            calorieDistribution: calorieDistribution
                        )
                    )
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedCalorieDistribution == nil)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingCalorieDistributionView(
            viewModel: OnboardingCalorieDistributionViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                preferredDiet: .balanced,
                calorieFloor: .standard,
                trainingType: .weightlifting
            )
        )
    }
    .previewEnvironment()
}

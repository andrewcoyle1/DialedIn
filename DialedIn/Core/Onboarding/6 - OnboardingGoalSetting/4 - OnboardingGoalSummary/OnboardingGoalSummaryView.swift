//
//  OnboardingGoalSummaryView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/10/2025.
//

import SwiftUI

struct OnboardingGoalSummaryView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.goalFlowDismissAction) private var dismissFlow
    @State var viewModel: OnboardingGoalSummaryViewModel
    @Binding var path: [OnboardingPathOption]

    var weightGoalBuilder: WeightGoalBuilder

    var body: some View {
        List {
            goalOverviewSection
            weightDetailsSection
            timelineSection
            motivationSection
        }
        .navigationTitle("Goal Summary")
        .scrollIndicators(.hidden)
        .onAppear {
            viewModel.onDismiss = dismissFlow
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
        .toolbar {
            toolbarContent
        }
        .showCustomAlert(alert: $viewModel.showAlert)
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
            if viewModel.isStandaloneMode {
                Button {
                    // Goal is saved in .task, just need to dismiss when ready
                    if viewModel.goalCreated {
                        viewModel.onDismiss?()
                    }
                } label: {
                    Text("Complete")
                }
                .buttonStyle(.glassProminent)
                .disabled(viewModel.isLoading || !viewModel.goalCreated)
            } else {
                Button {
                    viewModel.uploadGoalSettings(path: $path, weightGoalBuilder: weightGoalBuilder)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.glassProminent)
                .disabled(viewModel.isLoading)
            }
        }
    }
    
    // MARK: - View Sections
    
    private var goalOverviewSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: viewModel.objectiveIcon(objective: weightGoalBuilder.objective))
                        .font(.title2)
                        .foregroundColor(.accent)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Goal")
                            .font(.headline)
                        Text(objectiveTitle)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                
                Text(objectiveDetail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        } header: {
            Text("Goal Overview")
        }
    }
    
    private var weightDetailsSection: some View {
        Section {
            VStack(spacing: 16) {
                if let current = viewModel.currentWeight {
                    weightRow(
                        title: "Current Weight",
                        weight: current,
                        unit: viewModel.weightUnit
                    )
                }
                
                if let target = weightGoalBuilder.targetWeightKg {
                    weightRow(
                        title: "Target Weight",
                        weight: target,
                        unit: viewModel.weightUnit
                    )
                }
                
                if viewModel.weightDifference(targetWeight: weightGoalBuilder.targetWeightKg) != 0 {
                    Divider()
                    
                    HStack {
                        Text("Weight Change")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(viewModel.weightDifference(targetWeight: weightGoalBuilder.targetWeightKg) > 0 ? "+" : "")\(viewModel.formatWeight(abs(viewModel.weightDifference(targetWeight: weightGoalBuilder.targetWeightKg)), unit: viewModel.weightUnit))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.weightDifference(targetWeight: weightGoalBuilder.targetWeightKg) > 0 ? .green : .red)
                    }
                    
                    HStack {
                        Text("Weekly Rate")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(viewModel.formatWeight(weightGoalBuilder.weeklyChangeKg ?? 0, unit: viewModel.weightUnit))/week")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Weight Details")
        }
    }
    
    private var timelineSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundColor(.accent)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Estimated Timeline")
                            .font(.headline)
                        if viewModel.estimatedWeeks(weightGoalBuilder: weightGoalBuilder) > 0 {
                            Text("\(viewModel.estimatedWeeks) weeks (\(viewModel.estimatedMonths) months)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        } else {
                            Text("Maintaining current weight")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    Spacer()
                }
                
                if viewModel.estimatedWeeks(weightGoalBuilder: weightGoalBuilder) > 0 {
                    Text("Based on your selected rate of \(viewModel.formatWeight(weightGoalBuilder.weeklyChangeKg ?? 0, unit: viewModel.weightUnit)) per week")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Timeline")
        }
    }
    
    private var motivationSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundColor(.pink)
                    Text("You've Got This!")
                        .font(.headline)
                    Spacer()
                }
                
                Text(viewModel.motivationalMessage(objective: weightGoalBuilder.objective))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        } header: {
            Text("Motivation")
        }
    }
    
    // MARK: - Helper Methods
    
    private func weightRow(title: String, weight: Double, unit: WeightUnitPreference) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(viewModel.formatWeight(weight, unit: unit))
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

private extension OnboardingGoalSummaryView {
    var objectiveTitle: String {
        weightGoalBuilder.objective.description
    }
    
    var objectiveDetail: String {
        weightGoalBuilder.objective.detailedDescription
    }
}

#Preview("Normal") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        OnboardingGoalSummaryView(
            viewModel: OnboardingGoalSummaryViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path,
            weightGoalBuilder: WeightGoalBuilder.mock
        )
    }
    .previewEnvironment()
}

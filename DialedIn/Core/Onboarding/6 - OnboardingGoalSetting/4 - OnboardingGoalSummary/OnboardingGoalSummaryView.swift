//
//  OnboardingGoalSummaryView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingGoalSummaryView: View {

    @Environment(\.goalFlowDismissAction) private var dismissFlow

    @State var presenter: OnboardingGoalSummaryPresenter

    var delegate: OnboardingGoalSummaryDelegate

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
            presenter.onDismiss = dismissFlow
        }
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
            if presenter.isStandaloneMode {
                Button {
                    // Goal is saved in .task, just need to dismiss when ready
                    if presenter.goalCreated {
                        presenter.onDismiss?()
                    }
                } label: {
                    Text("Complete")
                }
                .buttonStyle(.glassProminent)
                .disabled(presenter.isLoading || !presenter.goalCreated)
            } else {
                Button {
                    presenter.uploadGoalSettings(weightGoalBuilder: delegate.weightGoalBuilder)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.glassProminent)
                .disabled(presenter.isLoading)
            }
        }
    }
    
    // MARK: - View Sections
    
    private var goalOverviewSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: presenter.objectiveIcon(objective: delegate.weightGoalBuilder.objective))
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
                if let current = presenter.currentWeight {
                    weightRow(
                        title: "Current Weight",
                        weight: current,
                        unit: presenter.weightUnit
                    )
                }
                
                if let target = delegate.weightGoalBuilder.targetWeightKg {
                    weightRow(
                        title: "Target Weight",
                        weight: target,
                        unit: presenter.weightUnit
                    )
                }
                
                if presenter.weightDifference(targetWeight: delegate.weightGoalBuilder.targetWeightKg) != 0 {
                    Divider()
                    
                    HStack {
                        Text("Weight Change")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(presenter.weightDifference(targetWeight: delegate.weightGoalBuilder.targetWeightKg) > 0 ? "+" : "")\(presenter.formatWeight(abs(presenter.weightDifference(targetWeight: delegate.weightGoalBuilder.targetWeightKg)), unit: presenter.weightUnit))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(presenter.weightDifference(targetWeight: delegate.weightGoalBuilder.targetWeightKg) > 0 ? .green : .red)
                    }
                    
                    HStack {
                        Text("Weekly Rate")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(presenter.formatWeight(delegate.weightGoalBuilder.weeklyChangeKg ?? 0, unit: presenter.weightUnit))/week")
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
                        if presenter.estimatedWeeks(weightGoalBuilder: delegate.weightGoalBuilder) > 0 {
                            Text("\(presenter.estimatedWeeks(weightGoalBuilder: delegate.weightGoalBuilder)) weeks (\(presenter.estimatedMonths(weightGoalBuilder: delegate.weightGoalBuilder)) months)")
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
                
                if presenter.estimatedWeeks(weightGoalBuilder: delegate.weightGoalBuilder) > 0 {
                    Text("Based on your selected rate of \(presenter.formatWeight(delegate.weightGoalBuilder.weeklyChangeKg ?? 0, unit: presenter.weightUnit)) per week")
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
                
                Text(presenter.motivationalMessage(objective: delegate.weightGoalBuilder.objective))
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
            Text(presenter.formatWeight(weight, unit: unit))
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

private extension OnboardingGoalSummaryView {
    var objectiveTitle: String {
        delegate.weightGoalBuilder.objective.description
    }
    
    var objectiveDetail: String {
        delegate.weightGoalBuilder.objective.detailedDescription
    }
}

#Preview("Normal") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingGoalSummaryView(
            router: router, 
            delegate: OnboardingGoalSummaryDelegate(weightGoalBuilder: .mock)
        )
    }
    .previewEnvironment()
}

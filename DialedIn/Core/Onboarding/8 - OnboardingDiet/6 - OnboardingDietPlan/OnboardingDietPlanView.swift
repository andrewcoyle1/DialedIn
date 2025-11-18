//
//  OnboardingDietPlanView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingDietPlanViewDelegate {
    var path: Binding<[OnboardingPathOption]>
    let dietPlanBuilder: DietPlanBuilder
}

struct OnboardingDietPlanView: View {

    @State var viewModel: OnboardingDietPlanViewModel

    var delegate: OnboardingDietPlanViewDelegate

    @ViewBuilder var devSettingsView: () -> AnyView

    var body: some View {
        List {
            if let plan = viewModel.plan {
                chartSection
                overviewSection(plan)
                weeklyBreakdownSection(plan)
            } else {
                Section {
                    Text("Generating your plan…")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Your Diet Plan")
        .toolbar {
            toolbarContent
        }
        .onAppear {
            viewModel.createPlan(dietPlanBuilder: delegate.dietPlanBuilder)
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            devSettingsView()
        }
        #endif
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: $viewModel.isLoading) {
            ProgressView()
                .tint(Color.white)
        }
    }
    
    private var chartSection: some View {
        Section("Weekly Calorie & Macro Breakdown") {
            if let plan = viewModel.plan {
                WeeklyMacroChart(plan: plan)
            }
        }
    }
    
    private func overviewSection(_ plan: DietPlan) -> some View {
        Section("Overview") {
            VStack(alignment: .leading, spacing: 8) {
                if let programName = viewModel.trainingProgramName,
                   let daysPerWeek = viewModel.trainingDaysPerWeek {
                    Text("Training program: \(programName), \(daysPerWeek) days/week")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)
                }
                Text("Estimated TDEE: \(Int(plan.tdeeEstimate)) kcal/day")
                Text("Preferred diet: \(plan.preferredDiet.capitalized)")
                Text("Calorie floor: \(plan.calorieFloor.capitalized)")
                Text("Training focus: \(plan.trainingType.replacingOccurrences(of: "_", with: " ").capitalized)")
                Text("Distribution: \(plan.calorieDistribution.capitalized)")
                Text("Protein: \(plan.proteinIntake.capitalized)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
    
    private func weeklyBreakdownSection(_ plan: DietPlan) -> some View {
        Section("7-day targets") {
            ForEach(Array(plan.days.enumerated()), id: \.offset) { idx, day in
                VStack(alignment: .leading, spacing: 6) {
                    Text("Day \(idx + 1)")
                        .font(.headline)
                    HStack(spacing: 16) {
                        labelValue("Calories", "\(Int(day.calories)) kcal")
                        labelValue("Protein", "\(Int(day.proteinGrams)) g")
                    }
                    HStack(spacing: 16) {
                        labelValue("Carbs", "\(Int(day.carbGrams)) g")
                        labelValue("Fat", "\(Int(day.fatGrams)) g")
                    }
                }
                .padding(.vertical, 6)
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
                viewModel.navigate(path: delegate.path)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private func labelValue(_ label: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.onboardingDietPlanView(
            delegate: OnboardingDietPlanViewDelegate(
                path: $path,
                dietPlanBuilder: .mock
            )
        )
    }
    .previewEnvironment()
}

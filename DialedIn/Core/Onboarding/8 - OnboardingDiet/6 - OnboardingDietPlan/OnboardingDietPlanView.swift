//
//  OnboardingDietPlanView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingDietPlanView: View {

    @State var presenter: OnboardingDietPlanPresenter

    var delegate: OnboardingDietPlanDelegate

    var body: some View {
        List {
            if let plan = presenter.plan {
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
            presenter.createPlan(dietPlanBuilder: delegate.dietPlanBuilder)
        }
    }
    
    private var chartSection: some View {
        Section("Weekly Calorie & Macro Breakdown") {
            if let plan = presenter.plan {
                WeeklyMacroChart(plan: plan)
            }
        }
    }
    
    private func overviewSection(_ plan: DietPlan) -> some View {
        Section("Overview") {
            VStack(alignment: .leading, spacing: 8) {
                if let programName = presenter.trainingProgramName,
                   let daysPerWeek = presenter.trainingDaysPerWeek {
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
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.navigate()
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

extension OnbBuilder {
    func onboardingDietPlanView(router: AnyRouter, delegate: OnboardingDietPlanDelegate) -> some View {
        OnboardingDietPlanView(
            presenter: OnboardingDietPlanPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension OnbRouter {
    func showOnboardingDietPlanView(delegate: OnboardingDietPlanDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingDietPlanView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingDietPlanView(
            router: router,
            delegate: OnboardingDietPlanDelegate(
                dietPlanBuilder: .mock
            )
        )
    }
    .previewEnvironment()
}

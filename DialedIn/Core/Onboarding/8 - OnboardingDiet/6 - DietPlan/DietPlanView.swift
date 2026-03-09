//
//  DietPlanView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct DietPlanDelegate {
    let preferredDiet: PreferredDiet
    let calorieFloor: CalorieFloor
    let calorieDistribution: CalorieDistribution
    let proteinIntake: ProteinIntake
    var isFromSettings: Bool

    init(oldDelegate delegate: ProteinIntakeDelegate, proteinIntake: ProteinIntake) {
        self.preferredDiet = delegate.preferredDiet
        self.calorieFloor = delegate.calorieFloor
        self.calorieDistribution = delegate.calorieDistrubtion
        self.proteinIntake = proteinIntake
        self.isFromSettings = delegate.isFromSettings
    }
    
    static var mock: Self {
        Self(oldDelegate: .mock, proteinIntake: .moderate)
    }
}

struct DietPlanView: View {

    @State var presenter: DietPlanPresenter

    var delegate: DietPlanDelegate

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
#if DEBUG || MOCK
.toolbar {
    toolbarContent
}
#endif
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.navigate()
            } label: {
                Text("Continue")
            }
            .accessibilityIdentifier("Continue")
        }
        .onAppear {
            presenter.createPlan(delegate: delegate)
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
    
    #if DEBUG || MOCK
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
    }
    #endif
    
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

extension CoreBuilder {
    func dietPlanView(router: AnyRouter, delegate: DietPlanDelegate) -> some View {
        DietPlanView(
            presenter: DietPlanPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showDietPlanView(delegate: DietPlanDelegate) {
        router.showScreen(.push) { router in
            builder.dietPlanView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.dietPlanView(
            router: router,
            delegate: .mock
        )
    }
    
}

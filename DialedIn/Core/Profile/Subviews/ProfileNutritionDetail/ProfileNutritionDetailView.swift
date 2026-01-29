//
//  ProfileNutritionDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProfileNutritionDetailView: View {
    
    @State var presenter: ProfileNutritionDetailPresenter
    
    var body: some View {
        List {
            if let plan = presenter.currentDietPlan {
                overviewSection(plan)
                weeklyBreakdownSection(plan)
                chartSection(plan)
            } else {
                Section {
                    Text("No nutrition plan available")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Nutrition Plan")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func overviewSection(_ plan: DietPlan) -> some View {
        Section("Plan Overview") {
            planCard(
                icon: "flame",
                label: "TDEE Estimate",
                value: "\(Int(plan.tdeeEstimate)) kcal/day",
                color: .red
            )
            
            planCard(
                icon: "leaf",
                label: "Diet Type",
                value: plan.preferredDiet.capitalized,
                color: .green
            )
            
            planCard(
                icon: "figure.strengthtraining.traditional",
                label: "Training Focus",
                value: plan.trainingType.replacingOccurrences(of: "_", with: " ").capitalized,
                color: .blue
            )
            
            planCard(
                icon: "chart.pie",
                label: "Distribution",
                value: plan.calorieDistribution.capitalized,
                color: .purple
            )
            
            planCard(
                icon: "p.circle.fill",
                label: "Protein Intake",
                value: plan.proteinIntake.capitalized,
                color: .orange
            )
            
            planCard(
                icon: "arrow.down.circle",
                label: "Calorie Floor",
                value: plan.calorieFloor.capitalized,
                color: .pink
            )
        }
    }
    
    private func weeklyBreakdownSection(_ plan: DietPlan) -> some View {
        Section("7-Day Targets") {
            ForEach(Array(plan.days.enumerated()), id: \.offset) { idx, day in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(dayName(idx))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(Int(day.calories)) kcal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.accent)
                    }
                    
                    HStack(spacing: 24) {
                        macroColumn(label: "Protein", value: Int(day.proteinGrams), color: .blue)
                        macroColumn(label: "Carbs", value: Int(day.carbGrams), color: .orange)
                        macroColumn(label: "Fat", value: Int(day.fatGrams), color: .green)
                    }
                }
            }
        }
    }
    
    private func chartSection(_ plan: DietPlan) -> some View {
        Section("Weekly Overview") {
            WeeklyMacroChart(plan: plan)
        }
    }
    
    private func planCard(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
    }
    
    private func macroColumn(label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)g")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private func dayName(_ index: Int) -> String {
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return days[safe: index] ?? "Day \(index + 1)"
    }
}

// MARK: - Array Extension
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension CoreBuilder {
    func profileNutritionDetailView(router: AnyRouter) -> some View {
        ProfileNutritionDetailView(
            presenter: ProfileNutritionDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showProfileNutritionDetailView() {
        router.showScreen(.push) { router in
            builder.profileNutritionDetailView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.profileNutritionDetailView(router: router)
    }
}

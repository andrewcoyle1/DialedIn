//
//  WeeklyMacroChart.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct WeeklyMacroChart: View {
    let plan: DietPlan
    
    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let maxCalories: Double
    
    init(plan: DietPlan) {
        self.plan = plan
        self.maxCalories = plan.days.map { $0.calories }.max() ?? 2000
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Chart Title
            HStack {
                Text("Daily Calorie Distribution")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("Avg: \(Int(plan.days.map { $0.calories }.reduce(0, +) / 7)) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Chart
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(plan.days.enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 6) {
                        // Stacked bar
                        VStack(spacing: 2) {
                            // Protein (bottom) - Blue
                            Rectangle()
                                .fill(Color(red: 0.2, green: 0.6, blue: 1.0))
                                .frame(height: barHeight(for: day.proteinGrams * 4)) // 4 cal/g
                                .cornerRadius(4)

                            // Carbs (middle) - Green
                            Rectangle()
                                .fill(Color(red: 0.3, green: 0.8, blue: 0.3))
                                .frame(height: barHeight(for: day.carbGrams * 4)) // 4 cal/g
                                .cornerRadius(4)

                            // Fat (top) - Orange
                            Rectangle()
                                .fill(Color(red: 1.0, green: 0.6, blue: 0.2))
                                .frame(height: barHeight(for: day.fatGrams * 9)) // 9 cal/g
                                .cornerRadius(4)

                        }
                        .frame(maxWidth: 40)
                        // .cornerRadius(8)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        
                        // Day label
                        Text(dayNames[index])
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        // Calorie total
                        Text("\(Int(day.calories))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .frame(height: 220)
            .padding(.horizontal, 8)
            
            // Legend
            HStack(spacing: 32) {
                LegendItem(color: Color(red: 0.2, green: 0.6, blue: 1.0), label: "Protein")
                LegendItem(color: Color(red: 0.3, green: 0.8, blue: 0.3), label: "Carbs")
                LegendItem(color: Color(red: 1.0, green: 0.6, blue: 0.2), label: "Fat")
            }
            .padding(.top, 8)
        }
    }
    
    private func barHeight(for calories: Double) -> CGFloat {
        let maxHeight: CGFloat = 200
        return max(3, (calories / maxCalories) * maxHeight)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(color)
                .frame(width: 16, height: 16)
                .cornerRadius(3)
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    let samplePlan = DietPlan(
        planId: "sample",
        userId: nil,
        createdAt: Date(),
        tdeeEstimate: 2200,
        preferredDiet: "balanced",
        calorieFloor: "standard",
        trainingType: "weightlifting",
        calorieDistribution: "varied",
        proteinIntake: "moderate",
        days: DailyMacroTarget.mocks
    )
    
    WeeklyMacroChart(plan: samplePlan)
        .padding()
}

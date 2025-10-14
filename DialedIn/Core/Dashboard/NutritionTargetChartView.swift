//
//  NutritionTargetChartView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct NutritionTargetChartView: View {
    @Environment(NutritionManager.self) private var nutritionManager
    @Environment(MealLogManager.self) private var mealLogManager
    
    @State private var loggedDays: [DailyMacroTarget] = Array(repeating: DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0), count: 7)
    private enum Metric: String, CaseIterable, Hashable {
        case calories = "Calories"
        case protein = "Protein"
        case carbs = "Carbohydrates"
        case fats = "Fats"
        
        var initial: String {
            switch self {
            case .calories:
                return "Cal"
            case .protein:
                return "P"
            case .carbs:
                return "C"
            case .fats:
                return "F"
            }
        }
        var colour: Color {
            switch self {
            case .calories: return .red
            case .protein: return .blue
            case .carbs: return .yellow
            case .fats: return .green
            }
        }
    }
    
    private var planDays: [DailyMacroTarget] {
        if let days = nutritionManager.currentDietPlan?.days, days.count == 7 {
            return days
        }
        return Array(repeating: .mock, count: 7)
    }
    
    private var mondayStartOfCurrentWeek: Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today) // Sunday=1
        let daysFromMonday = (weekday + 5) % 7 // Monday=0 .. Sunday=6
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
    }
    
    private var dayAbbrevs: [String] {
        let calendar = Calendar.current
        let symbols = calendar.veryShortWeekdaySymbols // [Sun, Mon, Tue, Wed, Thu, Fri, Sat]
        // Reorder to start with Monday: [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
        return Array(symbols[1...] + [symbols[0]])
    }
    
    // Monday-start day index for today (Mon=0 .. Sun=6)
    private var todayIndexMondayStart: Int {
        let weekday = Calendar.current.component(.weekday, from: Date()) // Sunday=1
        return (weekday + 5) % 7
    }
    
    var body: some View {
        Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 12) {
            // Metric rows
            ForEach(Metric.allCases, id: \.self) { metric in
                GridRow {
                    let targetValues = planDays.map { value(for: metric, day: $0) }
                    let loggedValues = loggedDays.map { value(for: metric, day: $0) }
                    let maxValue = max(targetValues.max() ?? 1, loggedValues.max() ?? 1)
                    let sumLogged = loggedValues.reduce(0, +)
                    let sumTarget = targetValues.reduce(0, +)
                    
                    // Day cells
                    ForEach(planDays.indices, id: \.self) { idx in
                        let logged = value(for: metric, day: loggedDays[idx])
                        let target = value(for: metric, day: planDays[idx])
                        TargetCellView(value: logged, targetValue: target, maxValue: maxValue, unit: unit(for: metric), tint: metric.colour)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor.opacity(idx == todayIndexMondayStart ? 0.9 : 0), lineWidth: 2)
                            )
                            .shadow(color: Color.accentColor.opacity(idx == todayIndexMondayStart ? 0.15 : 0), radius: 3, x: 0, y: 1)
                    }
                    
                    // Weekly sum cell
                    OverallTargetCellView(metricInitial: metric.initial, value: sumLogged, target: sumTarget, unit: unit(for: metric))
                        .fixedSize(horizontal: true, vertical: false)
                        .gridColumnAlignment(.leading)
                }
            }
            
            // Day labels row
            GridRow {
                ForEach(Array(dayAbbrevs.enumerated()), id: \.offset) { idx, day in
                    Text(day)
                        .font(.footnote)
                        .fontWeight(idx == todayIndexMondayStart ? .bold : .regular)
                        .foregroundStyle(idx == todayIndexMondayStart ? .accent : .secondary)
                        .padding(.horizontal, 2)
                }
                Text("Week")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .gridColumnAlignment(.leading)
            }
        }
        .task {
            await loadCurrentWeekLoggedTotals()
        }
    }
    
    private func value(for metric: Metric, day: DailyMacroTarget) -> Double {
        switch metric {
        case .calories: return day.calories
        case .protein: return day.proteinGrams
        case .carbs: return day.carbGrams
        case .fats: return day.fatGrams
        }
    }
    
    private func unit(for metric: Metric) -> String {
        switch metric {
        case .calories: return "kcal"
        default: return "g"
        }
    }
    
    @MainActor
    private func loadCurrentWeekLoggedTotals() async {
        let start = mondayStartOfCurrentWeek
        var totals: [DailyMacroTarget] = []
        totals.reserveCapacity(7)
        for offset in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: offset, to: start) ?? start
            let key = date.dayKey
            if let dayTotals = try? mealLogManager.getDailyTotals(dayKey: key) {
                totals.append(dayTotals)
            } else {
                totals.append(DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0))
            }
        }
        loggedDays = totals
    }
}

struct OverallTargetCellView: View {
    let metricInitial: String
    let value: Double
    let target: Double
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 0) {
                Text("\(Int(round(value)))")
                if metricInitial == "Cal" {
                    Image(systemName: "flame")
                } else {
                    Text(metricInitial)
                }
            }
            .font(.subheadline)
            .monospacedDigit()
            Text("of \(Int(target))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NutritionTargetChartView()
        .previewEnvironment()
}

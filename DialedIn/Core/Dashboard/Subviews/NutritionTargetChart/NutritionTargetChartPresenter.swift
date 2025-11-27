//
//  NutritionTargetChartPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

@Observable
@MainActor
class NutritionTargetChartPresenter {
    private let interactor: NutritionTargetChartInteractor
    
    var loggedDays: [DailyMacroTarget] = Array(repeating: DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0), count: 7)
    
    var planDays: [DailyMacroTarget] {
        if let days = interactor.currentDietPlan?.days, days.count == 7 {
            return days
        }
        return Array(repeating: .mock, count: 7)
    }
    
    var mondayStartOfCurrentWeek: Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today) // Sunday=1
        let daysFromMonday = (weekday + 5) % 7 // Monday=0 .. Sunday=6
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
    }
    
    var dayAbbrevs: [String] {
        let calendar = Calendar.current
        let symbols = calendar.veryShortWeekdaySymbols // [Sun, Mon, Tue, Wed, Thu, Fri, Sat]
        // Reorder to start with Monday: [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
        return Array(symbols[1...] + [symbols[0]])
    }
    
    // Monday-start day index for today (Mon=0 .. Sun=6)
    var todayIndexMondayStart: Int {
        let weekday = Calendar.current.component(.weekday, from: Date()) // Sunday=1
        return (weekday + 5) % 7
    }
    
    init(
        interactor: NutritionTargetChartInteractor
    ) {
        self.interactor = interactor
    }
    
    func value(for metric: Metric, day: DailyMacroTarget) -> Double {
        switch metric {
        case .calories: return day.calories
        case .protein: return day.proteinGrams
        case .carbs: return day.carbGrams
        case .fats: return day.fatGrams
        }
    }
    
    func unit(for metric: Metric) -> String {
        switch metric {
        case .calories: return "kcal"
        default: return "g"
        }
    }
    
    func loadCurrentWeekLoggedTotals() async {
        let start = mondayStartOfCurrentWeek
        var totals: [DailyMacroTarget] = []
        totals.reserveCapacity(7)
        for offset in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: offset, to: start) ?? start
            let key = date.dayKey
            if let dayTotals = try? interactor.getDailyTotals(dayKey: key) {
                totals.append(dayTotals)
            } else {
                totals.append(DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0))
            }
        }
        loggedDays = totals
    }
    
    enum Metric: String, CaseIterable, Hashable {
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
}

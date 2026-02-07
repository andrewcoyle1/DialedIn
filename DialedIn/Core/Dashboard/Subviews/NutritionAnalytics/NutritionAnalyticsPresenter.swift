import SwiftUI

@Observable
@MainActor
class NutritionAnalyticsPresenter {
    
    private let interactor: NutritionAnalyticsInteractor
    private let router: NutritionAnalyticsRouter
    private let calendar = Calendar.current
    
    var selectedDate: Date = Date()
    private(set) var dailyTotals: DailyMacroTarget?
    private(set) var dailyTarget: DailyMacroTarget?
    private(set) var dailyBreakdown: DailyNutritionBreakdown?
    private(set) var macrosLast7Days: [DailyMacroTarget] = []
    
    init(interactor: NutritionAnalyticsInteractor, router: NutritionAnalyticsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    var dayKey: String {
        selectedDate.dayKey
    }
    
    func loadData() async {
        // Load today's totals
        do {
            dailyTotals = try interactor.getDailyTotals(dayKey: dayKey)
        } catch {
            dailyTotals = nil
        }
        
        // Load today's target (if user has diet plan)
        if let userId = interactor.userId {
            do {
                dailyTarget = try await interactor.getDailyTarget(for: selectedDate, userId: userId)
            } catch {
                dailyTarget = nil
            }
        } else {
            dailyTarget = nil
        }
        
        // Load last 7 days for macros chart
        loadMacrosLast7Days()
        
        // Load detailed nutrition breakdown (from meal items + ingredient templates)
        do {
            dailyBreakdown = try interactor.getDailyNutritionBreakdown(dayKey: dayKey)
        } catch {
            dailyBreakdown = nil
        }
    }
    
    private func loadMacrosLast7Days() {
        let startOfSelected = calendar.startOfDay(for: selectedDate)
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: startOfSelected) else { return }
        
        var totals: [DailyMacroTarget] = []
        totals.reserveCapacity(7)
        for offset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: offset, to: startDate) ?? startDate
            let key = date.dayKey
            do {
                let dayTotals = try interactor.getDailyTotals(dayKey: key)
                totals.append(dayTotals)
            } catch {
                totals.append(DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0))
            }
        }
        macrosLast7Days = totals
    }
    
    // MARK: - Chart values (current, target, max for MacroProgressChart)
    
    var caloriesCurrent: Double { dailyTotals?.calories ?? 0 }
    var caloriesTarget: Double? { dailyTarget?.calories }
    var caloriesMax: Double {
        let target = dailyTarget?.calories ?? 2000
        return max(caloriesCurrent, target * 1.2)
    }
    
    var proteinCurrent: Double { dailyTotals?.proteinGrams ?? 0 }
    var proteinTarget: Double? { dailyTarget?.proteinGrams }
    var proteinMax: Double {
        let target = dailyTarget?.proteinGrams ?? 150
        return max(proteinCurrent, target * 1.2)
    }
    
    var fatCurrent: Double { dailyTotals?.fatGrams ?? 0 }
    var fatTarget: Double? { dailyTarget?.fatGrams }
    var fatMax: Double {
        let target = dailyTarget?.fatGrams ?? 80
        return max(fatCurrent, target * 1.2)
    }
    
    var carbsCurrent: Double { dailyTotals?.carbGrams ?? 0 }
    var carbsTarget: Double? { dailyTarget?.carbGrams }
    var carbsMax: Double {
        let target = dailyTarget?.carbGrams ?? 250
        return max(carbsCurrent, target * 1.2)
    }
    
    /// Average daily calories over last 7 days (for Macros card subsubtitle)
    var macrosAverageCalories: Double {
        guard !macrosLast7Days.isEmpty else { return 0 }
        return macrosLast7Days.map(\.calories).reduce(0, +) / Double(macrosLast7Days.count)
    }
    
    // MARK: - Breakdown helpers (for cards without targets)
    
    func formatBreakdown(_ value: Double?, unit: String) -> String {
        guard let value, value > 0 else { return "--" }
        if value >= 100 || value == floor(value) {
            return Int(value).formatted()
        }
        return value.formatted(.number.precision(.fractionLength(1)))
    }
    
    func breakdownChartMax(current: Double?, defaultMax: Double) -> Double {
        let curr = current ?? 0
        return max(curr * 1.2, defaultMax)
    }

    // MARK: - Navigation

    func onMacrosPressed() {
        router.showNutritionMetricDetailView(metric: .macros, delegate: NutritionMetricDetailDelegate())
    }

    func onCaloriesPressed() {
        router.showNutritionMetricDetailView(metric: .calories, delegate: NutritionMetricDetailDelegate())
    }

    func onProteinPressed() {
        router.showNutritionMetricDetailView(metric: .protein, delegate: NutritionMetricDetailDelegate())
    }

    func onFatPressed() {
        router.showNutritionMetricDetailView(metric: .fat, delegate: NutritionMetricDetailDelegate())
    }

    func onCarbsPressed() {
        router.showNutritionMetricDetailView(metric: .carbs, delegate: NutritionMetricDetailDelegate())
    }

    func onBreakdownMetricPressed(_ metric: NutritionMetric) {
        router.showNutritionMetricDetailView(metric: metric, delegate: NutritionMetricDetailDelegate())
    }
}

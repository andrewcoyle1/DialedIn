import SwiftUI

@MainActor
protocol NutritionAnalyticsInteractor {
    var userId: String? { get }
    func trackEvent(event: LoggableEvent)
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget
    func getDailyTotals(startDayKey: String, endDayKey: String) throws -> [(dayKey: String, totals: DailyMacroTarget)]
    func getDailyTarget(for date: Date, userId: String) async throws -> DailyMacroTarget?
    func getMeals(startDayKey: String, endDayKey: String) throws -> [MealLogModel]
    func getDailyNutritionBreakdown(dayKey: String) throws -> DailyNutritionBreakdown
    func getDailyNutritionBreakdown(startDayKey: String, endDayKey: String) throws -> [(dayKey: String, breakdown: DailyNutritionBreakdown)]
}

extension CoreInteractor: NutritionAnalyticsInteractor { }

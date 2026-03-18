import SwiftUI

@MainActor
protocol NutritionOverviewInteractor: GlobalInteractor {
    var userId: String? { get }
    var currentUser: UserModel? { get }
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget
    func getDailyNutritionBreakdown(dayKey: String) throws -> DailyNutritionBreakdown
    func getDailyTarget(for date: Date, userId: String) async throws -> DailyMacroTarget?
    func getMeals(for dayKey: String) throws -> [MealLogModel]
}

extension CoreInteractor: NutritionOverviewInteractor { }

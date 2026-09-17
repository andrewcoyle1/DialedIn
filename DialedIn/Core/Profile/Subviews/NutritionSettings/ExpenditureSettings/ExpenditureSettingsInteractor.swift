import SwiftUI

@MainActor
protocol ExpenditureSettingsInteractor: GlobalInteractor {
    var nutritionStrategySettings: NutritionStrategySettings { get }
    func saveNutritionStrategySettings(_ settings: NutritionStrategySettings) async throws
}

extension CoreInteractor: ExpenditureSettingsInteractor { }

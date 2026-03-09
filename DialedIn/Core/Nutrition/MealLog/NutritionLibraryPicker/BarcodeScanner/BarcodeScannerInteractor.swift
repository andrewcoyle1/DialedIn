import SwiftUI

@MainActor
protocol BarcodeScannerInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func analyzeNutritionLabel(text: String) async throws -> String
    func saveFood(_ ingredient: FoodModel, image: PlatformImage?) async throws
    func lookupBarcode(_ code: String) async throws -> FoodModel
}

extension CoreInteractor: BarcodeScannerInteractor {
    func lookupBarcode(_ code: String) async throws -> FoodModel {
        try await openFoodFactsService.lookupBarcode(code)
    }
}

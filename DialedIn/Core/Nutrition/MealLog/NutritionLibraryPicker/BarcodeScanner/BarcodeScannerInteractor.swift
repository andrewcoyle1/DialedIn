import SwiftUI

@MainActor
protocol BarcodeScannerInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func analyzeNutritionLabel(text: String) async throws -> String
    func saveFood(_ ingredient: FoodModel, image: PlatformImage?) async throws
}

extension CoreInteractor: BarcodeScannerInteractor { }

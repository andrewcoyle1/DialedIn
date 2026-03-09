import SwiftUI

@MainActor
protocol FoodPhotoScannerInteractor: GlobalInteractor {
    func analyzeFood(imageData: Data) async throws -> String
}

extension CoreInteractor: FoodPhotoScannerInteractor { }

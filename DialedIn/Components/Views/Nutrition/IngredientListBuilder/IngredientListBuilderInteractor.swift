import SwiftUI

@MainActor
protocol IngredientListBuilderInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var foods: [FoodModel] { get }
}

extension CoreInteractor: IngredientListBuilderInteractor { }

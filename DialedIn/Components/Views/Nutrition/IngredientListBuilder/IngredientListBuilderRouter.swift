import SwiftUI

@MainActor
protocol IngredientListBuilderRouter: GlobalRouter {
    func showCreateFoodView(delegate: CreateFoodDelegate)
    func showMealItemAmountViewView(delegate: MealItemAmountViewDelegate)
}

extension CoreRouter: IngredientListBuilderRouter { }

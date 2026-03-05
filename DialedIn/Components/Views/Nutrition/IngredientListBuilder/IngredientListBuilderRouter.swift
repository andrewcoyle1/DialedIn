import SwiftUI

@MainActor
protocol IngredientListBuilderRouter: GlobalRouter {
    func showCreateFoodView(delegate: CreateFoodDelegate)
}

extension CoreRouter: IngredientListBuilderRouter { }

import SwiftUI

@MainActor
protocol IngredientListBuilderRouter: GlobalRouter {
    func showCreateIngredientView()
}

extension CoreRouter: IngredientListBuilderRouter { }

import SwiftUI

@MainActor
protocol RecipeListBuilderRouter: GlobalRouter {
    func showRecipeDetailView(delegate: RecipeDetailDelegate)
    func showCreateRecipeView()
}

extension CoreRouter: RecipeListBuilderRouter { }

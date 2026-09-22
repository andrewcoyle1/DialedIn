//
//  RecipeDetailPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

@Observable
@MainActor
class RecipeDetailPresenter {
    private let interactor: RecipeDetailInteractor
    private let router: RecipeDetailRouter

    var isBookmarked: Bool = false
    var isFavourited: Bool = false

    var showStartSessionSheet: Bool = false
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    init(
        interactor: RecipeDetailInteractor,
        router: RecipeDetailRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
        
    func onViewAppear(delegate: RecipeDetailDelegate) {
        isFavourited = interactor.isFavouriteRecipe(id: delegate.recipeTemplate.id)
    }

    /// Favourites live on the food log settings, which is what the library's Favourites tab reads.
    func onFavouritePressed(delegate: RecipeDetailDelegate) {
        let newValue = !isFavourited
        isFavourited = newValue
        Task {
            do {
                try await interactor.setFavouriteRecipe(id: delegate.recipeTemplate.id, isFavourite: newValue)
            } catch {
                isFavourited = !newValue
            }
        }
    }

    func displayUnit(_ unit: IngredientAmountUnit) -> String {
        switch unit {
        case .grams: return "g"
        case .milliliters: return "ml"
        case .units: return "units"
        }
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif

    func onStartRecipePressed(recipe: RecipeTemplateModel) {
        router.showStartRecipeView(delegate: RecipeStartDelegate(recipe: recipe))
    }
}

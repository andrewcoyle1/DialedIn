//
//  RecipeDetailPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

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

    private(set) var isDeleting: Bool = false

    func canDelete(recipe: RecipeTemplateModel) -> Bool {
        recipe.authorId != nil && recipe.authorId == currentUser?.userId
    }

    func showDeleteConfirmation(recipe: RecipeTemplateModel) {
        router.showAlert(title: "Delete Recipe", subtitle: "Are you sure you want to delete '\(recipe.name)'? This action cannot be undone.", buttons: {
            AnyView(
                HStack {
                    Button("Delete", role: .destructive) {
                        Task {
                            await self.deleteRecipe(recipe, onDismiss: { self.router.dismissScreen() })
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
            )
        })
    }

    /// `onDismiss` is the router's dismiss in the app; a parameter so a test can see it happen.
    func deleteRecipe(_ recipe: RecipeTemplateModel, onDismiss: @escaping () -> Void) async {
        isDeleting = true
        do {
            try await interactor.deleteRecipeTemplate(id: recipe.id)
            onDismiss()
        } catch {
            isDeleting = false
            router.showSimpleAlert(title: "Failed to delete recipe", subtitle: "Please try again later")
        }
    }
}

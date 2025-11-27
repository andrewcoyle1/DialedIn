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
    
    func loadInitialState(recipeTemplate: RecipeTemplateModel) {
        let user = currentUser
        // Always treat authored templates as bookmarked
        let isAuthor = user?.userId == recipeTemplate.authorId
        isBookmarked = isAuthor || (user?.bookmarkedRecipeTemplateIds?.contains(recipeTemplate.id) ?? false) || (user?.createdRecipeTemplateIds?.contains(recipeTemplate.id) ?? false)
        isFavourited = user?.favouritedRecipeTemplateIds?.contains(recipeTemplate.id) ?? false
    }
    
    func displayUnit(_ unit: IngredientAmountUnit) -> String {
        switch unit {
        case .grams: return "g"
        case .milliliters: return "ml"
        case .units: return "units"
        }
    }
    
    func onBookmarkPressed(recipeTemplate: RecipeTemplateModel) async {
        let newState = !isBookmarked
        do {
            // If unbookmarking and currently favourited, unfavourite first to enforce rule
            if !newState && isFavourited {
                try await interactor.favouriteRecipeTemplate(id: recipeTemplate.id, isFavourited: false)
                isFavourited = false
                // Remove from user's favourited list
                try await interactor.removeFavouritedRecipeTemplate(recipeId: recipeTemplate.id)
            }
            try await interactor.bookmarkRecipeTemplate(id: recipeTemplate.id, isBookmarked: newState)
            if newState {
                try await interactor.addBookmarkedRecipeTemplate(recipeId: recipeTemplate.id)
            } else {
                try await interactor.removeBookmarkedRecipeTemplate(recipeId: recipeTemplate.id)
            }
            isBookmarked = newState
        } catch {
            router.showSimpleAlert(title: "Failed to update bookmark status", subtitle: "Please try again later")
        }
    }
    
    func onFavoritePressed(recipeTemplate: RecipeTemplateModel) async {
        let newState = !isFavourited
        do {
            // If favouriting and not bookmarked, bookmark first to enforce rule
            if newState && !isBookmarked {
                try await interactor.bookmarkRecipeTemplate(id: recipeTemplate.id, isBookmarked: true)
                try await interactor.addBookmarkedRecipeTemplate(recipeId: recipeTemplate.id)
                isBookmarked = true
            }
            try await interactor.favouriteRecipeTemplate(id: recipeTemplate.id, isFavourited: newState)
            if newState {
                try await interactor.addFavouritedRecipeTemplate(recipeId: recipeTemplate.id)
            } else {
                try await interactor.removeFavouritedRecipeTemplate(recipeId: recipeTemplate.id)
            }
            isFavourited = newState
        } catch {
            router.showSimpleAlert(title: "Failed to update favourite status", subtitle: "Please try again later")
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func onStartRecipePressed(recipe: RecipeTemplateModel) {
        router.showStartRecipeView(delegate: RecipeStartDelegate(recipe: recipe))
    }
}

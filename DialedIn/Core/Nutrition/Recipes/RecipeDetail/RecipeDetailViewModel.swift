//
//  RecipeDetailViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

protocol RecipeDetailInteractor {
    var currentUser: UserModel? { get }
    func favouriteRecipeTemplate(id: String, isFavourited: Bool) async throws
    func addFavouritedRecipeTemplate(recipeId: String) async throws
    func removeFavouritedRecipeTemplate(recipeId: String) async throws
    func bookmarkRecipeTemplate(id: String, isBookmarked: Bool) async throws
    func addBookmarkedRecipeTemplate(recipeId: String) async throws
    func removeBookmarkedRecipeTemplate(recipeId: String) async throws
}

extension CoreInteractor: RecipeDetailInteractor { }

@Observable
@MainActor
class RecipeDetailViewModel {
    private let interactor: RecipeDetailInteractor
    
    let recipeTemplate: RecipeTemplateModel
    
    var isBookmarked: Bool = false
    var isFavourited: Bool = false

    var showStartSessionSheet: Bool = false
    var showAlert: AnyAppAlert?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    init(
        interactor: RecipeDetailInteractor,
        recipeTemplate: RecipeTemplateModel
    ) {
        self.interactor = interactor
        self.recipeTemplate = recipeTemplate
    }
    
    func loadInitialState() {
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
    
    func onBookmarkPressed() async {
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
            showAlert = AnyAppAlert(title: "Failed to update bookmark status", subtitle: "Please try again later")
        }
    }
    
    func onFavoritePressed() async {
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
            showAlert = AnyAppAlert(title: "Failed to update favourite status", subtitle: "Please try again later")
        }
    }
}

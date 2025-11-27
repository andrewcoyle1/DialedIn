//
//  RecipeDetailInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

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

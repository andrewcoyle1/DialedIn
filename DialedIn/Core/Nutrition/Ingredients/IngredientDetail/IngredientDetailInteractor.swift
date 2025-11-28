//
//  IngredientDetailInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol IngredientDetailInteractor {
    var currentUser: UserModel? { get }
    func favouriteIngredientTemplate(id: String, isFavourited: Bool) async throws
    func removeFavouritedIngredientTemplate(ingredientId: String) async throws
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) async throws
    func addBookmarkedIngredientTemplate(ingredientId: String) async throws
    func removeBookmarkedIngredientTemplate(ingredientId: String) async throws
    func addFavouritedIngredientTemplate(ingredientId: String) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: IngredientDetailInteractor { }

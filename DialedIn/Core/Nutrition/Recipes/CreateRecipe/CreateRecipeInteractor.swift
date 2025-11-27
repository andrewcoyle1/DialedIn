//
//  CreateRecipeInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

protocol CreateRecipeInteractor {
    var currentUser: UserModel? { get }
    func createRecipeTemplate(recipe: RecipeTemplateModel, image: PlatformImage?) async throws
    func addCreatedRecipeTemplate(recipeId: String) async throws
    func addBookmarkedRecipeTemplate(recipeId: String) async throws
    func bookmarkRecipeTemplate(id: String, isBookmarked: Bool) async throws
    func generateImage(input: String) async throws -> UIImage
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
}

extension CoreInteractor: CreateRecipeInteractor { }

//
//  RemoteTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

protocol RemoteRecipeTemplateService {
    func createRecipeTemplate(recipe: RecipeTemplateModel, image: PlatformImage?) async throws
    func getRecipeTemplate(id: String) async throws -> RecipeTemplateModel
    func getRecipeTemplates(ids: [String], limitTo: Int) async throws -> [RecipeTemplateModel]
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel]
    func getRecipeTemplatesForAuthor(authorId: String) async throws -> [RecipeTemplateModel]
    func getTopRecipeTemplatesByClicks(limitTo: Int) async throws -> [RecipeTemplateModel]
    func incrementRecipeTemplateInteraction(id: String) async throws
    func removeAuthorIdFromRecipeTemplate(id: String) async throws
    func removeAuthorIdFromAllRecipeTemplates(id: String) async throws
    func bookmarkRecipeTemplate(id: String, isBookmarked: Bool) async throws
    func favouriteRecipeTemplate(id: String, isFavourited: Bool) async throws
}

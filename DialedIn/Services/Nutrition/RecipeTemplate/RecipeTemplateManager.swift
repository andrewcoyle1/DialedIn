//
//  RecipeTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@MainActor
@Observable
class RecipeTemplateManager: BaseTemplateManager<RecipeTemplateModel> {
    
    init(services: RecipeTemplateServices) {
        super.init(
            addLocal: { try services.local.addLocalRecipeTemplate(recipe: $0) },
            getLocal: { try services.local.getLocalRecipeTemplate(id: $0) },
            getLocalMany: { try services.local.getLocalRecipeTemplates(ids: $0) },
            getAllLocal: { try services.local.getAllLocalRecipeTemplates() },
            deleteLocal: nil,
            createRemote: { try await services.remote.createRecipeTemplate(recipe: $0, image: $1) },
            updateRemote: nil,
            deleteRemote: nil,
            getRemote: { try await services.remote.getRecipeTemplate(id: $0) },
            getRemoteMany: { try await services.remote.getRecipeTemplates(ids: $0, limitTo: $1) },
            getByNameRemote: { try await services.remote.getRecipeTemplatesByName(name: $0) },
            getForAuthorRemote: { try await services.remote.getRecipeTemplatesForAuthor(authorId: $0) },
            getTopByClicksRemote: { try await services.remote.getTopRecipeTemplatesByClicks(limitTo: $0) },
            incrementRemote: { try await services.remote.incrementRecipeTemplateInteraction(id: $0) },
            removeAuthorIdRemote: { try await services.remote.removeAuthorIdFromRecipeTemplate(id: $0) },
            removeAuthorIdFromAllRemote: { try await services.remote.removeAuthorIdFromAllRecipeTemplates(id: $0) },
            bookmarkRemote: { try await services.remote.bookmarkRecipeTemplate(id: $0, isBookmarked: $1) },
            favouriteRemote: { try await services.remote.favouriteRecipeTemplate(id: $0, isFavourited: $1) }
        )
    }
    
    // MARK: - Method Aliases for Backward Compatibility
    
    func addLocalRecipeTemplate(recipe: RecipeTemplateModel) async throws {
        try await addLocalTemplate(recipe)
    }
    
    func getLocalRecipeTemplate(id: String) throws -> RecipeTemplateModel {
        try getLocalTemplate(id: id)
    }
    
    func getLocalRecipeTemplates(ids: [String]) throws -> [RecipeTemplateModel] {
        try getLocalTemplates(ids: ids)
    }
    
    func getAllLocalRecipeTemplates() throws -> [RecipeTemplateModel] {
        try getAllLocalTemplates()
    }
    
    func createRecipeTemplate(recipe: RecipeTemplateModel, image: PlatformImage?) async throws {
        try await createTemplate(recipe, image: image)
    }
    
    func getRecipeTemplate(id: String) async throws -> RecipeTemplateModel {
        try await getTemplate(id: id)
    }
    
    func getRecipeTemplates(ids: [String], limitTo: Int = 20) async throws -> [RecipeTemplateModel] {
        try await getTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel] {
        try await getTemplatesByName(name: name)
    }
    
    func getRecipeTemplatesForAuthor(authorId: String) async throws -> [RecipeTemplateModel] {
        try await getTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopRecipeTemplatesByClicks(limitTo: Int = 10) async throws -> [RecipeTemplateModel] {
        try await getTopTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementRecipeTemplateInteraction(id: String) async throws {
        try await incrementTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromRecipeTemplate(id: String) async throws {
        try await removeAuthorIdFromTemplate(id: id)
    }
    
    func removeAuthorIdFromAllRecipeTemplates(id: String) async throws {
        try await removeAuthorIdFromAllTemplates(id: id)
    }
    
    func bookmarkRecipeTemplate(id: String, isBookmarked: Bool) async throws {
        try await bookmarkTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteRecipeTemplate(id: String, isFavourited: Bool) async throws {
        try await favouriteTemplate(id: id, isFavourited: isFavourited)
    }
}
 

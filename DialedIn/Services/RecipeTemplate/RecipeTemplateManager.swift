//
//  RecipeTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@MainActor
@Observable
class RecipeTemplateManager {
    
    private let local: LocalRecipeTemplatePersistence
    private let remote: RemoteRecipeTemplateService
    
    init(services: RecipeTemplateServices) {
        self.remote = services.remote
        self.local = services.local
    }
    
    func addLocalRecipeTemplate(recipe: RecipeTemplateModel) async throws {
        try local.addLocalRecipeTemplate(recipe: recipe)
        try await remote.incrementRecipeTemplateInteraction(id: recipe.id)
    }
    
    func getLocalRecipeTemplate(id: String) throws -> RecipeTemplateModel {
        try local.getLocalRecipeTemplate(id: id)
    }
    
    func getLocalRecipeTemplates(ids: [String]) throws -> [RecipeTemplateModel] {
        try local.getLocalRecipeTemplates(ids: ids)
    }
    
    func getAllLocalRecipeTemplates() throws -> [RecipeTemplateModel] {
        try local.getAllLocalRecipeTemplates()
    }
    
    func createRecipeTemplate(recipe: RecipeTemplateModel, image: PlatformImage?) async throws {
        try await remote.createRecipeTemplate(recipe: recipe, image: image)
    }
    
    func getRecipeTemplate(id: String) async throws -> RecipeTemplateModel {
        try await remote.getRecipeTemplate(id: id)
    }
    
    func getRecipeTemplates(ids: [String], limitTo: Int = 20) async throws -> [RecipeTemplateModel] {
        try await remote.getRecipeTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel] {
        try await remote.getRecipeTemplatesByName(name: name)
    }
    
    func getRecipeTemplatesForAuthor(authorId: String) async throws -> [RecipeTemplateModel] {
        try await remote.getRecipeTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopRecipeTemplatesByClicks(limitTo: Int = 10) async throws -> [RecipeTemplateModel] {
        try await remote.getTopRecipeTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementRecipeTemplateInteraction(id: String) async throws {
        try await remote.incrementRecipeTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromRecipeTemplate(id: String) async throws {
        try await remote.removeAuthorIdFromRecipeTemplate(id: id)
    }
    
    func removeAuthorIdFromAllRecipeTemplates(id: String) async throws {
        try await remote.removeAuthorIdFromAllRecipeTemplates(id: id)
    }
    
    func bookmarkRecipeTemplate(id: String, isBookmarked: Bool) async throws {
        try await remote.bookmarkRecipeTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteRecipeTemplate(id: String, isFavourited: Bool) async throws {
        try await remote.favouriteRecipeTemplate(id: id, isFavourited: isFavourited)
    }
}

//
//  IngredientTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@MainActor
@Observable
class IngredientTemplateManager {
    
    private let local: LocalIngredientTemplatePersistence
    private let remote: RemoteIngredientTemplateService
    
    init(services: IngredientTemplateServices) {
        self.remote = services.remote
        self.local = services.local
    }
    
    func addLocalIngredientTemplate(ingredient: IngredientTemplateModel) async throws {
        try local.addLocalIngredientTemplate(ingredient: ingredient)
        try await remote.incrementIngredientTemplateInteraction(id: ingredient.id)
    }
    
    func getLocalIngredientTemplate(id: String) throws -> IngredientTemplateModel {
        try local.getLocalIngredientTemplate(id: id)
    }
    
    func getLocalIngredientTemplates(ids: [String]) throws -> [IngredientTemplateModel] {
        try local.getLocalIngredientTemplates(ids: ids)
    }
    
    func getAllLocalIngredientTemplates() throws -> [IngredientTemplateModel] {
        try local.getAllLocalIngredientTemplates()
    }
    
    func createIngredientTemplate(ingredient: IngredientTemplateModel, image: PlatformImage?) async throws {
        try await remote.createIngredientTemplate(ingredient: ingredient, image: image)
    }
    
    func getIngredientTemplate(id: String) async throws -> IngredientTemplateModel {
        try await remote.getIngredientTemplate(id: id)
    }
    
    func getIngredientTemplates(ids: [String], limitTo: Int = 20) async throws -> [IngredientTemplateModel] {
        try await remote.getIngredientTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel] {
        try await remote.getIngredientTemplatesByName(name: name)
    }
    
    func getIngredientTemplatesForAuthor(authorId: String) async throws -> [IngredientTemplateModel] {
        try await remote.getIngredientTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopIngredientTemplatesByClicks(limitTo: Int = 10) async throws -> [IngredientTemplateModel] {
        try await remote.getTopIngredientTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementIngredientTemplateInteraction(id: String) async throws {
        try await remote.incrementIngredientTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromIngredientTemplate(id: String) async throws {
        try await remote.removeAuthorIdFromIngredientTemplate(id: id)
    }
    
    func removeAuthorIdFromAllIngredientTemplates(id: String) async throws {
        try await remote.removeAuthorIdFromAllIngredientTemplates(id: id)
    }
    
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) async throws {
        try await remote.bookmarkIngredientTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteIngredientTemplate(id: String, isFavourited: Bool) async throws {
        try await remote.favouriteIngredientTemplate(id: id, isFavourited: isFavourited)
    }
}

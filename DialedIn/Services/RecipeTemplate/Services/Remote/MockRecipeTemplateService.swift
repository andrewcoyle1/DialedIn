//
//  MockRecipeTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct MockRecipeTemplateService: RemoteRecipeTemplateService {
    let recipes: [RecipeTemplateModel]
    let delay: Double
    let showError: Bool
    
    init(recipes: [RecipeTemplateModel] = RecipeTemplateModel.mocks, delay: Double = 0.0, showError: Bool = false) {
        self.recipes = recipes
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createRecipeTemplate(recipe: RecipeTemplateModel, image: PlatformImage?) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    func getRecipeTemplate(id: String) async throws -> RecipeTemplateModel {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        guard let recipe = recipes.first(where: { $0.id == id}) else {
            throw URLError(.unknown)
        }
        
        return recipe
    }
    
    func getRecipeTemplates(ids: [String], limitTo: Int = 20) async throws -> [RecipeTemplateModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return recipes.shuffled()
    }
    
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return recipes.shuffled()
    }
    
    func getRecipeTemplatesForAuthor(authorId: String) async throws -> [RecipeTemplateModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return recipes.shuffled()
    }
    
    func getTopRecipeTemplatesByClicks(limitTo: Int) async throws -> [RecipeTemplateModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return recipes
            .sorted { ($0.clickCount ?? 0) > ($1.clickCount ?? 0) }
            .prefix(limitTo)
            .map { $0 }
    }
    
    func incrementRecipeTemplateInteraction(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeAuthorIdFromRecipeTemplate(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeAuthorIdFromAllRecipeTemplates(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func bookmarkRecipeTemplate(id: String, isBookmarked: Bool) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func favouriteRecipeTemplate(id: String, isFavourited: Bool) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
}

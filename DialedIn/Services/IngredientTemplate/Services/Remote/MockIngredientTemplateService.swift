//
//  MockIngredientTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct MockIngredientTemplateService: RemoteIngredientTemplateService {
    let ingredients: [IngredientTemplateModel]
    let delay: Double
    let showError: Bool
    
    init(ingredients: [IngredientTemplateModel] = IngredientTemplateModel.mocks, delay: Double = 0.0, showError: Bool = false) {
        self.ingredients = ingredients
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createIngredientTemplate(ingredient: IngredientTemplateModel, image: PlatformImage?) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    func getIngredientTemplate(id: String) async throws -> IngredientTemplateModel {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        guard let ingredient = ingredients.first(where: { $0.id == id}) else {
            throw URLError(.unknown)
        }
        
        return ingredient
    }
    
    func getIngredientTemplates(ids: [String], limitTo: Int = 20) async throws -> [IngredientTemplateModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return ingredients.shuffled()
    }
    
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return ingredients.shuffled()
    }
    
    func getIngredientTemplatesForAuthor(authorId: String) async throws -> [IngredientTemplateModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return ingredients.shuffled()
    }
    
    func getTopIngredientTemplatesByClicks(limitTo: Int) async throws -> [IngredientTemplateModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return ingredients
            .sorted { ($0.clickCount ?? 0) > ($1.clickCount ?? 0) }
            .prefix(limitTo)
            .map { $0 }
    }
    
    func incrementIngredientTemplateInteraction(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeAuthorIdFromIngredientTemplate(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeAuthorIdFromAllIngredientTemplates(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func favouriteIngredientTemplate(id: String, isFavourited: Bool) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
}

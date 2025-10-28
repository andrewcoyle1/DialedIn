//
//  MockIngredientTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import Foundation

struct MockIngredientTemplatePersistence: LocalIngredientTemplatePersistence {
    
    var ingredientTemplates: [IngredientTemplateModel]
    var showError: Bool
    
    init(ingredients: [IngredientTemplateModel] = IngredientTemplateModel.mocks, showError: Bool = false) {
        self.ingredientTemplates = ingredients
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func addLocalIngredientTemplate(ingredient: IngredientTemplateModel) throws {
        try tryShowError()
    }
    func getLocalIngredientTemplate(id: String) throws -> IngredientTemplateModel {
        try tryShowError()

        if let template = ingredientTemplates.first(where: { $0.id == id }) {
            return template
        } else {
            throw NSError(domain: "MockIngredientTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "IngredientTemplate with id \(id) not found"])
        }
    }
    func getLocalIngredientTemplates(ids: [String]) throws -> [IngredientTemplateModel] {
        try tryShowError()

        return ingredientTemplates.filter { ids.contains($0.id) }
    }
    
    func getAllLocalIngredientTemplates() throws -> [IngredientTemplateModel] {
        try tryShowError()

        return ingredientTemplates
    }
    
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) throws {
        try tryShowError()
        // No-op in mock; in a real implementation, this would update the bookmark status in persistent storage.
    }
    
    func favouriteIngredientTemplate(id: String, isFavourited: Bool) throws {
        try tryShowError()
        // No-op in mock; in a real implementation, this would update the favourite status in persistent storage.
    }
}

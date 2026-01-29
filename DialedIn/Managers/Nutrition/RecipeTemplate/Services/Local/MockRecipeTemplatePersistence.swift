//
//  MockExerciseTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import Foundation

struct MockRecipeTemplatePersistence: LocalRecipeTemplatePersistence {
    
    var recipeTemplates: [RecipeTemplateModel]
    var showError: Bool
    
    init(recipes: [RecipeTemplateModel] = RecipeTemplateModel.mocks, showError: Bool = false) {
        self.recipeTemplates = recipes
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func addLocalRecipeTemplate(recipe: RecipeTemplateModel) throws {
        try tryShowError()
    }
    func getLocalRecipeTemplate(id: String) throws -> RecipeTemplateModel {
        try tryShowError()

        if let template = recipeTemplates.first(where: { $0.id == id }) {
            return template
        } else {
            throw NSError(domain: "MockRecipeTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "RecipeTemplate with id \(id) not found"])
        }
    }
    func getLocalRecipeTemplates(ids: [String]) throws -> [RecipeTemplateModel] {
        try tryShowError()

        return recipeTemplates.filter { ids.contains($0.id) }
    }
    
    func getAllLocalRecipeTemplates() throws -> [RecipeTemplateModel] {
        try tryShowError()

        return recipeTemplates
    }
    
    func bookmarkRecipeTemplate(id: String, isBookmarked: Bool) throws {
        try tryShowError()
        // No-op in mock; in a real implementation, this would update the bookmark status in persistent storage.
    }
    
    func favouriteRecipeTemplate(id: String, isFavourited: Bool) throws {
        try tryShowError()
        // No-op in mock; in a real implementation, this would update the favourite status in persistent storage.
    }
}

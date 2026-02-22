//
//  LocatExerciseTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

@MainActor
protocol LocalRecipeTemplatePersistence {
    func addLocalRecipeTemplate(recipe: RecipeTemplateModel) throws
    func getLocalRecipeTemplate(id: String) throws -> RecipeTemplateModel
    func getLocalRecipeTemplates(ids: [String]) throws -> [RecipeTemplateModel]
    func getAllLocalRecipeTemplates() throws -> [RecipeTemplateModel]
    func bookmarkRecipeTemplate(id: String, isBookmarked: Bool) throws
}

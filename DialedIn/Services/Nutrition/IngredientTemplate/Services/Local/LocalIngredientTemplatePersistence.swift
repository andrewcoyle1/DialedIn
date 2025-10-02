//
//  LocatIngredientTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

@MainActor
protocol LocalIngredientTemplatePersistence {
    func addLocalIngredientTemplate(ingredient: IngredientTemplateModel) throws
    func getLocalIngredientTemplate(id: String) throws -> IngredientTemplateModel
    func getLocalIngredientTemplates(ids: [String]) throws -> [IngredientTemplateModel]
    func getAllLocalIngredientTemplates() throws -> [IngredientTemplateModel]
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) throws
    func favouriteIngredientTemplate(id: String, isFavourited: Bool) throws
}

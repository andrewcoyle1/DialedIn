//
//  NutritionLibraryPickerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol NutritionLibraryPickerInteractor: Sendable {
    func getTopIngredientTemplatesByClicks(limitTo: Int) async throws -> [IngredientTemplateModel]
    func getTopRecipeTemplatesByClicks(limitTo: Int) async throws -> [RecipeTemplateModel]
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel]
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel]
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: NutritionLibraryPickerInteractor, @unchecked Sendable { }

//
//  RecipesInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol RecipesInteractor {
    var currentUser: UserModel? { get }
    func getRecipeTemplates(ids: [String], limitTo: Int) async throws -> [RecipeTemplateModel]
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel]
    func getRecipeTemplatesForAuthor(authorId: String) async throws -> [RecipeTemplateModel]
    func incrementRecipeTemplateInteraction(id: String) async throws
    func getTopRecipeTemplatesByClicks(limitTo: Int) async throws -> [RecipeTemplateModel]
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: RecipesInteractor { }

//
//  RecipeTemplateListViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

protocol RecipeTemplateListInteractor {
    func getRecipeTemplates(ids: [String], limitTo: Int) async throws -> [RecipeTemplateModel]
}

extension CoreInteractor: RecipeTemplateListInteractor { }

@MainActor
protocol RecipeTemplateListRouter {
    func showDevSettingsView()
}

extension CoreRouter: RecipeTemplateListRouter { }

// Typealias for backward compatibility
typealias RecipeTemplateListViewModel = GenericTemplateListViewModel<RecipeTemplateModel>

extension GenericTemplateListViewModel where Template == RecipeTemplateModel {
    static func create(
        interactor: RecipeTemplateListInteractor,
        router: RecipeTemplateListRouter,
        templateIds: [String]?
    ) -> RecipeTemplateListViewModel {
        return GenericTemplateListViewModel<RecipeTemplateModel>(
            configuration: .recipe,
            templateIds: templateIds,
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getRecipeTemplates(ids: ids, limitTo: limit)
            }
        )
    }
    
    // Convenience create for non-optional templateIds (backward compatibility)
    static func create(
        interactor: RecipeTemplateListInteractor,
        router: RecipeTemplateListRouter,
        templateIds: [String]
    ) -> RecipeTemplateListViewModel {
        return GenericTemplateListViewModel<RecipeTemplateModel>(
            configuration: .recipe,
            templateIds: templateIds,
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getRecipeTemplates(ids: ids, limitTo: limit)
            }
        )
    }
}

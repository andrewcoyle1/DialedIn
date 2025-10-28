//
//  IngredientTemplateListViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

protocol IngredientTemplateListInteractor {
    func getIngredientTemplates(ids: [String], limitTo: Int) async throws -> [IngredientTemplateModel]
}

extension CoreInteractor: IngredientTemplateListInteractor { }

// Typealias for backward compatibility
typealias IngredientTemplateListViewModel = GenericTemplateListViewModel<IngredientTemplateModel>

extension GenericTemplateListViewModel where Template == IngredientTemplateModel {
    static func create(
        interactor: IngredientTemplateListInteractor,
        templateIds: [String]?
    ) -> IngredientTemplateListViewModel {
        return GenericTemplateListViewModel<IngredientTemplateModel>(
            configuration: .ingredient,
            templateIds: templateIds,
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getIngredientTemplates(ids: ids, limitTo: limit)
            }
        )
    }
    
    // Convenience create for non-optional templateIds (backward compatibility)
    static func create(
        interactor: IngredientTemplateListInteractor,
        templateIds: [String]
    ) -> IngredientTemplateListViewModel {
        return GenericTemplateListViewModel<IngredientTemplateModel>(
            configuration: .ingredient,
            templateIds: templateIds,
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getIngredientTemplates(ids: ids, limitTo: limit)
            }
        )
    }
}

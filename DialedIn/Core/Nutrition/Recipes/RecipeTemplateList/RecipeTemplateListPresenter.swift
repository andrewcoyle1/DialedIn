//
//  RecipeTemplateListPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

// Typealias for backward compatibility
typealias RecipeTemplateListPresenter = GenericTemplateListPresenter<RecipeTemplateModel>

extension GenericTemplateListPresenter where Template == RecipeTemplateModel {
    static func create(
        interactor: RecipeTemplateListInteractor,
        router: RecipeTemplateListRouter,
        templateIds: [String]?
    ) -> RecipeTemplateListPresenter {
        return GenericTemplateListPresenter<RecipeTemplateModel>(
            configuration: .recipe,
            templateIds: templateIds,
            showAlert: { title, subtitle in
                router.showSimpleAlert(title: title, subtitle: subtitle)
            },
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
    ) -> RecipeTemplateListPresenter {
        return GenericTemplateListPresenter<RecipeTemplateModel>(
            configuration: .recipe,
            templateIds: templateIds,
            showAlert: { title, subtitle in
                router.showSimpleAlert(title: title, subtitle: subtitle)
            },
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getRecipeTemplates(ids: ids, limitTo: limit)
            }
        )
    }
}

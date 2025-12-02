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
        let configuration: TemplateListConfiguration<RecipeTemplateModel> = .recipe
            .with(navigationDestination: { template in
                router.showRecipeDetailView(delegate: RecipeDetailDelegate(recipeTemplate: template))
            })

        return GenericTemplateListPresenter<RecipeTemplateModel>(
            configuration: configuration,
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
        let configuration: TemplateListConfiguration<RecipeTemplateModel> = .recipe
            .with(navigationDestination: { template in
                router.showRecipeDetailView(delegate: RecipeDetailDelegate(recipeTemplate: template))
            })

        return GenericTemplateListPresenter<RecipeTemplateModel>(
            configuration: configuration,
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

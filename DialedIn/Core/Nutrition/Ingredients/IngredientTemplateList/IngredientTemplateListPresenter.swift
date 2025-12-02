//
//  IngredientTemplateListPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

// Typealias for backward compatibility
typealias IngredientTemplateListPresenter = GenericTemplateListPresenter<IngredientTemplateModel>

extension GenericTemplateListPresenter where Template == IngredientTemplateModel {
    static func create(
        interactor: IngredientTemplateListInteractor,
        router: IngredientTemplateListRouter,
        templateIds: [String]?
    ) -> IngredientTemplateListPresenter {
        let configuration: TemplateListConfiguration<IngredientTemplateModel> = .ingredient
            .with(navigationDestination: { template in
                router.showIngredientDetailView(delegate: IngredientDetailDelegate(ingredientTemplate: template))
            })

        return GenericTemplateListPresenter<IngredientTemplateModel>(
            configuration: configuration,
            templateIds: templateIds,
            showAlert: { title, subtitle in
                router.showSimpleAlert(title: title, subtitle: subtitle)
            },
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getIngredientTemplates(ids: ids, limitTo: limit)
            }
        )
    }
    
    // Convenience create for non-optional templateIds (backward compatibility)
    static func create(
        interactor: IngredientTemplateListInteractor,
        router: IngredientTemplateListRouter,
        delegate: IngredientTemplateListDelegate
    ) -> IngredientTemplateListPresenter {
        let configuration: TemplateListConfiguration<IngredientTemplateModel> = .ingredient
            .with(navigationDestination: { template in
                router.showIngredientDetailView(delegate: IngredientDetailDelegate(ingredientTemplate: template))
            })

        return GenericTemplateListPresenter<IngredientTemplateModel>(
            configuration: configuration,
            templateIds: delegate.templateIds,
            showAlert: { title, subtitle in
                router.showSimpleAlert(title: title, subtitle: subtitle)
            },
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getIngredientTemplates(ids: ids, limitTo: limit)
            }
        )
    }
}

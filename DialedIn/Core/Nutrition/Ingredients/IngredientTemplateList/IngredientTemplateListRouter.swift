//
//  IngredientTemplateListRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol IngredientTemplateListRouter {
    func showDevSettingsView()
    func showIngredientDetailView(delegate: IngredientDetailDelegate)
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: IngredientTemplateListRouter { }

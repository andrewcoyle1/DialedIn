//
//  RecipeDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol RecipeDetailRouter {
    func showDevSettingsView()
    func showStartRecipeView(delegate: RecipeStartDelegate)
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: RecipeDetailRouter { }

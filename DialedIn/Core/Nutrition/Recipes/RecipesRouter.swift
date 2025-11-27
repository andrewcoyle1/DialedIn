//
//  RecipesRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol RecipesRouter {
    func showRecipeDetailView(delegate: RecipeDetailDelegate)
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: RecipesRouter { }

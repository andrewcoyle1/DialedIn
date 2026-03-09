//
//  CreateRecipeRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol CreateRecipeRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showAddIngredientView(delegate: AddFoodDelegate)
    func showRecipePreparationView(delegate: RecipePreparationDelegate)
}

extension CoreRouter: CreateRecipeRouter { }

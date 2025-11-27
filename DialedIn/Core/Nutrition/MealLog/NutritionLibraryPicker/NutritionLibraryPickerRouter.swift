//
//  NutritionLibraryPickerRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol NutritionLibraryPickerRouter {
    func showIngredientAmountView(delegate: IngredientAmountDelegate)
    func showRecipeAmountView(delegate: RecipeAmountDelegate)
    func showDevSettingsView()
    func showAlert(error: Error)
    func dismissScreen()
}

extension CoreRouter: NutritionLibraryPickerRouter { }

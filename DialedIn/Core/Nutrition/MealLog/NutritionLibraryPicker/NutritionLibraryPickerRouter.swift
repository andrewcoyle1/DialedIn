//
//  NutritionLibraryPickerRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol NutritionLibraryPickerRouter: GlobalRouter {
    func showIngredientAmountView(delegate: IngredientAmountDelegate)
    func showRecipeAmountView(delegate: RecipeAmountDelegate)
#if DEV || MOCK
func showDevSettingsView()
#endif
}

extension CoreRouter: NutritionLibraryPickerRouter { }

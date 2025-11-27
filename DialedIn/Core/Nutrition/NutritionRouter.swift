//
//  NutritionRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol NutritionRouter {
    func showNotificationsView()
    func showDevSettingsView()
    func showCreateIngredientView()
    func showCreateRecipeView()
}

extension CoreRouter: NutritionRouter { }

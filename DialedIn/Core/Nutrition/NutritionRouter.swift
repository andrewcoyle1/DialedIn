//
//  NutritionRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol NutritionRouter: GlobalRouter {
    func showNotificationsView()
    func showDevSettingsView()
    
    func showAddMealView(delegate: AddMealDelegate)
    func showMealDetailView(delegate: MealDetailDelegate)

    func showRecipesView()
    func showIngredientsView()
}

extension CoreRouter: NutritionRouter { }

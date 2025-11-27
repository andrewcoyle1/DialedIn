//
//  CreateRecipeRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol CreateRecipeRouter {
    func showDevSettingsView()
    func showAddIngredientView(delegate: AddIngredientModalDelegate)
    func dismissScreen()
    func showAlert(error: Error)
}

extension CoreRouter: CreateRecipeRouter { }

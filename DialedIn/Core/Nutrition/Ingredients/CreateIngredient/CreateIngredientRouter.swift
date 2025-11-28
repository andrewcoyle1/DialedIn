//
//  CreateIngredientRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol CreateIngredientRouter {
    func showDevSettingsView()
    func showAlert(error: Error)

    func dismissScreen()
}

extension CoreRouter: CreateIngredientRouter { }

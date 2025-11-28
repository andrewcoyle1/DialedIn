//
//  IngredientDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol IngredientDetailRouter {
    func showDevSettingsView()
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: IngredientDetailRouter { }

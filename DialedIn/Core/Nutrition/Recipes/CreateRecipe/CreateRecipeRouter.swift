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
    func showAddIngredientView(delegate: AddIngredientModalDelegate)
}

extension CoreRouter: CreateRecipeRouter { }

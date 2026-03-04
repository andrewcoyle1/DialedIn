//
//  RecipeDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol RecipeDetailRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showStartRecipeView(delegate: RecipeStartDelegate)
}

extension CoreRouter: RecipeDetailRouter { }

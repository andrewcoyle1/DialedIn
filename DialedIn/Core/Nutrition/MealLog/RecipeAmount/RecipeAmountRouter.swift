//
//  RecipeAmountRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol RecipeAmountRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
}

extension CoreRouter: RecipeAmountRouter { }

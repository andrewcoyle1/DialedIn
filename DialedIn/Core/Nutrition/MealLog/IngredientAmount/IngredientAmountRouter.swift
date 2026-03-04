//
//  IngredientAmountRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol IngredientAmountRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
}

extension CoreRouter: IngredientAmountRouter { }

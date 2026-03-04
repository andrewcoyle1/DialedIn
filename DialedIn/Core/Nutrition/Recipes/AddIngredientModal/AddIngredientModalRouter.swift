//
//  AddIngredientModalRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol AddIngredientModalRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
}

extension CoreRouter: AddIngredientModalRouter { }

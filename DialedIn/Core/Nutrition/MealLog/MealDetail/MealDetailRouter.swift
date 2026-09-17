//
//  MealDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol MealDetailRouter: GlobalRouter {
    func showSimpleAlert(title: String, subtitle: String?)
#if DEV || MOCK
func showDevSettingsView()
#endif
}

extension CoreRouter: MealDetailRouter { }

//
//  ProfileNutritionDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProfileNutritionDetailRouter {
    func showDevSettingsView()
}

extension CoreRouter: ProfileNutritionDetailRouter { }

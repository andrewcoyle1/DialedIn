//
//  ProfileNutritionPlanRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProfileNutritionPlanRouter {
    func showProfileNutritionDetailView()
    func showDevSettingsView()
}

extension CoreRouter: ProfileNutritionPlanRouter { }

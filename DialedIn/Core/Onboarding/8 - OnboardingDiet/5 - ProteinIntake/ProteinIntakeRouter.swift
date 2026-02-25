//
//  ProteinIntakeRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProteinIntakeRouter {
    func showDevSettingsView()
    func showDietPlanView(delegate: DietPlanDelegate)
}

extension CoreRouter: ProteinIntakeRouter { }

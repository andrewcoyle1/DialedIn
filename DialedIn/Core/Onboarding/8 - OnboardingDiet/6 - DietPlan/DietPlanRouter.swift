//
//  DietPlanRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol DietPlanRouter: GlobalRouter {
    func showDevSettingsView()
    func showOnboardingCompletedView()

    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: DietPlanRouter { }

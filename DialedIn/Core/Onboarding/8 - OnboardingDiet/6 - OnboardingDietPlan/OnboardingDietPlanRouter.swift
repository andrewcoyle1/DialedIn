//
//  OnboardingDietPlanRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingDietPlanRouter {
    func showDevSettingsView()
    func showOnboardingCompletedView()

    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: OnboardingDietPlanRouter { }

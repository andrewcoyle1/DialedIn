//
//  OnboardingProteinIntakeRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingProteinIntakeRouter {
    func showDevSettingsView()
    func showOnboardingDietPlanView(delegate: OnboardingDietPlanDelegate)
}

extension CoreRouter: OnboardingProteinIntakeRouter { }

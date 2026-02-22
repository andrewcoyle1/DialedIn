//
//  OnboardingCalorieDistributionRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingCalorieDistributionRouter {
    func showDevSettingsView()
    func showOnboardingProteinIntakeView(delegate: OnboardingProteinIntakeDelegate)
}

extension CoreRouter: OnboardingCalorieDistributionRouter { }

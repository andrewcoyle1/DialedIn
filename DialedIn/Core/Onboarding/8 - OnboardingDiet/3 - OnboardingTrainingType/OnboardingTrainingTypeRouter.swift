//
//  OnboardingTrainingTypeRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingTrainingTypeRouter {
    func showDevSettingsView()
    func showOnboardingCalorieDistributionView(delegate: OnboardingCalorieDistributionDelegate)
}

extension OnbRouter: OnboardingTrainingTypeRouter { }

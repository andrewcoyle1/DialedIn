//
//  OnboardingCalorieFloorRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingCalorieFloorRouter {
    func showDevSettingsView()
    func showOnboardingCalorieDistributionView(delegate: OnboardingCalorieDistributionDelegate)
    func showOnboardingTrainingTypeView(delegate: OnboardingTrainingTypeDelegate)
}

extension CoreRouter: OnboardingCalorieFloorRouter { }

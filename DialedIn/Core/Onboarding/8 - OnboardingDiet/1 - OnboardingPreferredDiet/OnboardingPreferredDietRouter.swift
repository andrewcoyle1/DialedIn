//
//  OnboardingPreferredDietRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingPreferredDietRouter {
    func showDevSettingsView()
    func showOnboardingCalorieFloorView(delegate: OnboardingCalorieFloorDelegate)
}

extension OnbRouter: OnboardingPreferredDietRouter { }

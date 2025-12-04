//
//  OnboardingCustomisingProgramRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingCustomisingProgramRouter {
    func showDevSettingsView()
    func showOnboardingPreferredDietView()
    func showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceDelegate)
}

extension OnbRouter: OnboardingCustomisingProgramRouter { }

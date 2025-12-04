//
//  OnboardingTrainingExperienceRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingTrainingExperienceRouter {
    func showDevSettingsView()
    func showOnboardingTrainingDaysPerWeekView(delegate: OnboardingTrainingDaysPerWeekDelegate)
}

extension OnbRouter: OnboardingTrainingExperienceRouter { }

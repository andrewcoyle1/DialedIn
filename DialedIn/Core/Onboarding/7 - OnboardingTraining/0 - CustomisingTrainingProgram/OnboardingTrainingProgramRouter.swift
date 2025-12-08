//
//  OnboardingTrainingProgramRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingTrainingProgramRouter: GlobalRouter {
    func showDevSettingsView()
    func showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceDelegate)
}

extension OnbRouter: OnboardingTrainingProgramRouter { }

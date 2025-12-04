//
//  OnboardingGoalSummaryRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingGoalSummaryRouter {
    func showDevSettingsView()
    func showOnboardingTrainingProgramView()

    func showSimpleAlert(title: String, subtitle: String?)
}

extension OnbRouter: OnboardingGoalSummaryRouter { }

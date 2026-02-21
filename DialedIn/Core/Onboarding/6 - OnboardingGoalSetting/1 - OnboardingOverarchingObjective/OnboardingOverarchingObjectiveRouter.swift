//
//  OnboardingOverarchingObjectiveRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingOverarchingObjectiveRouter {
    func showDevSettingsView()
    func showOnboardingTargetWeightView(delegate: OnboardingTargetWeightDelegate)
    func showOnboardingGoalSummaryView(delegate: OnboardingGoalSummaryDelegate)
}

extension CoreRouter: OnboardingOverarchingObjectiveRouter { }

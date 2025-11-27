//
//  OnboardingGoalSettingRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingGoalSettingRouter {
    func showDevSettingsView()
    func showOnboardingOverarchingObjectiveView()
}

extension CoreRouter: OnboardingGoalSettingRouter { }

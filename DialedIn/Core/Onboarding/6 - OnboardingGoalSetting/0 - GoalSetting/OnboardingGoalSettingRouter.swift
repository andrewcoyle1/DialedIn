//
//  OnboardingGoalSettingRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingGoalSettingRouter: GlobalRouter {
    func showDevSettingsView()
    func showOnboardingOverarchingObjectiveView()
}

extension OnbRouter: OnboardingGoalSettingRouter { }

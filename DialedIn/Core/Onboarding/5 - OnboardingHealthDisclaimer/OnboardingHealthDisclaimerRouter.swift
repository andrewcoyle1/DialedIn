//
//  OnboardingHealthDisclaimerRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingHealthDisclaimerRouter {
    func showDevSettingsView()
    func showOnboardingGoalSettingView()
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: OnboardingHealthDisclaimerRouter { }

//
//  OnboardingSubscriptionPlanRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingSubscriptionPlanRouter {
    func showDevSettingsView()
    func showOnboardingCompleteAccountSetupView()
    func showOnboardingNotificationsView()
    func showOnboardingHealthDataView()
    func showOnboardingHealthDisclaimerView()
    func showOnboardingGoalSettingView()
    func showOnboardingCustomisingProgramView()
    func showOnboardingCompletedView()

    func showSimpleAlert(title: String, subtitle: String?)
}

extension OnbRouter: OnboardingSubscriptionPlanRouter { }

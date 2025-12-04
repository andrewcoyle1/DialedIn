//
//  OnboardingWelcomeRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingWelcomeRouter {
    func showDevSettingsView()
    func showOnboardingIntroView()
    func showAuthOptionsView()
    func showSubscriptionView()
    func showOnboardingCompleteAccountSetupView()
    func showOnboardingNotificationsView()
    func showOnboardingHealthDataView()
    func showOnboardingHealthDisclaimerView()
    func showOnboardingGoalSettingView()
    func showOnboardingCustomisingProgramView()
    func showOnboardingCompletedView()
}

extension OnbRouter: OnboardingWelcomeRouter { }

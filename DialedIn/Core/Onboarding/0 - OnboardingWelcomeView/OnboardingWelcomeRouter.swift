//
//  OnboardingWelcomeRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingWelcomeRouter: GlobalRouter {
    func showDevSettingsView()
    func showPaywall()
    func showPaywall(onPurchaseSuccess: @escaping @MainActor () -> Void)
    func showOnboardingIntroView()
    func showOnboardingAuthView()
    func showSubscriptionView()
    func showOnboardingCompleteAccountSetupView()
    func showOnboardingNotificationsView()
    func showOnboardingHealthDataView()
    func showOnboardingHealthDisclaimerView()
    func showOnboardingGoalSettingView()
    func showOnboardingCustomisingProgramView()
    func showOnboardingCompletedView()
    func switchToCoreModule()
}

extension CoreRouter: OnboardingWelcomeRouter { }

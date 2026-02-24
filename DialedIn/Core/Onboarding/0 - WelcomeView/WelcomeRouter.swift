//
//  WelcomeRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WelcomeRouter: GlobalRouter {
    func showDevSettingsView()
    func showPaywall()
    func showPaywall(onPurchaseSuccess: @escaping @MainActor () -> Void)
    func showIntroView()
    func showAuthView()
    func showSubscriptionView()
    func showCompleteAccountSetupView()
    func showNotificationsPermissionsView()
    func showOnboardingHealthDataView()
    func showHealthDisclaimerView()
    func showGoalSettingView()
    func showCreateGymProfileView(delegate: CreateGymProfileDelegate)
    func showOnboardingTrainingProgramView(delegate: CreateProgramDelegate)
    func showOnboardingCustomisingProgramView()
    func showOnboardingCompletedView()
    func switchToCoreModule()
}

extension CoreRouter: WelcomeRouter { }

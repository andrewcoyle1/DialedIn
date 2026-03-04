//
//  WelcomeRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WelcomeRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showPaywall(isOnboarding: Bool)
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
    func showCustomisingDietProgramView()
    func showOnboardingCompletedView()
    func switchToCoreModule()
}

extension CoreRouter: WelcomeRouter { }

//
//  AuthRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol AuthRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showCompleteAccountSetupView()
    func showNotificationsPermissionsView()
    func showOnboardingHealthDataView()
    func showHealthDisclaimerView()
    func showGoalSettingView()
    func showCreateGymProfileView(delegate: CreateGymProfileDelegate)
    func showOnboardingTrainingProgramView(delegate: CreateProgramDelegate)
    func showCustomisingDietProgramView()
    func showOnboardingCompletedView()
    
    func showPaywall(isOnboarding: Bool)
    func showSubscriptionView()
    func switchToCoreModule()
}

extension CoreRouter: AuthRouter { }

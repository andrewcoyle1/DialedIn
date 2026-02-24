//
//  AuthRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol AuthRouter: GlobalRouter {
    func showDevSettingsView()
    func showCompleteAccountSetupView()
    func showNotificationsPermissionsView()
    func showOnboardingHealthDataView()
    func showHealthDisclaimerView()
    func showGoalSettingView()
    func showCreateGymProfileView(delegate: CreateGymProfileDelegate)
    func showOnboardingTrainingProgramView(delegate: CreateProgramDelegate)
    func showOnboardingCustomisingProgramView()
    func showOnboardingCompletedView()
    
    func showPaywall()
    func showPaywall(onPurchaseSuccess: @escaping @MainActor () -> Void)
    func showSubscriptionView()
    func switchToCoreModule()
}

extension CoreRouter: AuthRouter { }

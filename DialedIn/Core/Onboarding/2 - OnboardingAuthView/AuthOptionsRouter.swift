//
//  OnboardingAuthRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol OnboardingAuthRouter: GlobalRouter {
    func showDevSettingsView()
    func showOnboardingCompleteAccountSetupView()
    func showOnboardingNotificationsView()
    func showOnboardingHealthDataView()
    func showOnboardingHealthDisclaimerView()
    func showOnboardingGoalSettingView()
    func showOnboardingCustomisingProgramView()
    func showOnboardingCompletedView()
    
    func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
    func showPaywall()
    func showPaywall(onPurchaseSuccess: @escaping @MainActor () -> Void)
    func showSubscriptionView()
    func switchToCoreModule()
}

extension CoreRouter: OnboardingAuthRouter { }

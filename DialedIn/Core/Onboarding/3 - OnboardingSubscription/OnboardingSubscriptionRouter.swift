//
//  OnboardingSubscriptionRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingSubscriptionRouter {
    func showDevSettingsView()
    func showPaywall()
    func showPaywall(onPurchaseSuccess: @escaping @MainActor () -> Void)
    func showOnboardingCompleteAccountSetupView()
}

extension CoreRouter: OnboardingSubscriptionRouter { }

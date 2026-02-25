//
//  SubscriptionRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol SubscriptionRouter {
    func showDevSettingsView()
    func showPaywall(isOnboarding: Bool)
    func showCompleteAccountSetupView()
}

extension CoreRouter: SubscriptionRouter { }

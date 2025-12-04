//
//  OnboardingSubscriptionRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingSubscriptionRouter {
    func showDevSettingsView()
    func showSubscriptionPlanView()
}

extension OnbRouter: OnboardingSubscriptionRouter { }

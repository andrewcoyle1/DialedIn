//
//  OnboardingTargetWeightRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingTargetWeightRouter {
    func showDevSettingsView()
    func showOnboardingWeightRateView(delegate: OnboardingWeightRateDelegate)
}

extension CoreRouter: OnboardingTargetWeightRouter { }

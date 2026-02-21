//
//  OnboardingHeightRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingHeightRouter {
    func showDevSettingsView()
    func showOnboardingWeightView(delegate: OnboardingWeightDelegate)
}

extension CoreRouter: OnboardingHeightRouter { }

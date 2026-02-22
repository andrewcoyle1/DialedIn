//
//  OnboardingActivityRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingActivityRouter {
    func showDevSettingsView()
    func showOnboardingCardioFitnessView(delegate: OnboardingCardioFitnessDelegate)
}

extension CoreRouter: OnboardingActivityRouter { }

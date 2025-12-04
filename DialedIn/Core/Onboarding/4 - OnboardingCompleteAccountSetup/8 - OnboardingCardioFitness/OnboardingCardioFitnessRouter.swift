//
//  OnboardingCardioFitnessRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingCardioFitnessRouter {
    func showDevSettingsView()
    func showOnboardingExpenditureView(delegate: OnboardingExpenditureDelegate)
}

extension OnbRouter: OnboardingCardioFitnessRouter { }

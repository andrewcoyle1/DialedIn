//
//  OnboardingHealthDataRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingHealthDataRouter {
    func showDevSettingsView()
    func showOnboardingHealthDisclaimerView()

    func showAlert(error: Error)
}

extension CoreRouter: OnboardingHealthDataRouter { }

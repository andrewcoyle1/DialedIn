//
//  OnboardingDateOfBirthRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingDateOfBirthRouter {
    func showDevSettingsView()
    func showOnboardingHeightView(delegate: OnboardingHeightDelegate)
}

extension OnbRouter: OnboardingDateOfBirthRouter { }

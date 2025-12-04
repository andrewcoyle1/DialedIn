//
//  OnboardingGenderRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingGenderRouter {
    func showDevSettingsView()
    func showOnboardingDateOfBirthView(delegate: OnboardingDateOfBirthDelegate)
}

extension OnbRouter: OnboardingGenderRouter { }

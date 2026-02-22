//
//  OnboardingCompletedRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingCompletedRouter: GlobalRouter {
    func showDevSettingsView()

    func switchToCoreModule()
}

extension CoreRouter: OnboardingCompletedRouter { }

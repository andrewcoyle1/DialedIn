//
//  OnboardingIntroRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingIntroRouter {
    func showDevSettingsView()
    func showOnboardingAuthView()
}

extension CoreRouter: OnboardingIntroRouter { }

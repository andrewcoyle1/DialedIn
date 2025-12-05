//
//  OnboardingIntroRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingIntroRouter {
    func showDevSettingsView()
    func showOnboardingAuthView()
}

extension OnbRouter: OnboardingIntroRouter { }

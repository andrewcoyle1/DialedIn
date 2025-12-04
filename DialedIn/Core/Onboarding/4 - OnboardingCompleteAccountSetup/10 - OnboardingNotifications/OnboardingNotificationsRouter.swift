//
//  OnboardingNotificationsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingNotificationsRouter {
    func showDevSettingsView()
    func showOnboardingHealthDataView()
    func showOnboardingHealthDisclaimerView()
}

extension OnbRouter: OnboardingNotificationsRouter { }

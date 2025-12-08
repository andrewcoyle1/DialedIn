//
//  OnboardingDietPlanRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingDietPlanRouter: GlobalRouter {
    func showDevSettingsView()
    func showOnboardingCompletedView()

    func showSimpleAlert(title: String, subtitle: String?)
}

extension OnbRouter: OnboardingDietPlanRouter { }

//
//  OnboardingWeightRateRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingWeightRateRouter {
    func showDevSettingsView()
    func showOnboardingGoalSummaryView(delegate: OnboardingGoalSummaryDelegate)
}

extension OnbRouter: OnboardingWeightRateRouter { }

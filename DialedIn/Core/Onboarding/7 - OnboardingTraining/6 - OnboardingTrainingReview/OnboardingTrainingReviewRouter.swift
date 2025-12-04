//
//  OnboardingTrainingReviewRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingTrainingReviewRouter {
    func showDevSettingsView()
    func showOnboardingCustomisingProgramView()

    func showSimpleAlert(title: String, subtitle: String?)
}

extension OnbRouter: OnboardingTrainingReviewRouter { }

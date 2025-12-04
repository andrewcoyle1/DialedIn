//
//  OnboardingExerciseFrequencyRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingExerciseFrequencyRouter {
    func showDevSettingsView()
    func showOnboardingActivityView(delegate: OnboardingActivityDelegate)
}

extension OnbRouter: OnboardingExerciseFrequencyRouter { }

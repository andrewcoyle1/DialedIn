//
//  OnboardingTrainingDaysPerWeekRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingTrainingDaysPerWeekRouter {
    func showDevSettingsView()
    func showOnboardingTrainingSplitView(delegate: OnboardingTrainingSplitDelegate)
}

extension CoreRouter: OnboardingTrainingDaysPerWeekRouter { }

//
//  OnboardingTrainingScheduleRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingTrainingScheduleRouter {
    func showDevSettingsView()
    func showOnboardingTrainingEquipmentView(delegate: OnboardingTrainingEquipmentDelegate)
}

extension OnbRouter: OnboardingTrainingScheduleRouter { }

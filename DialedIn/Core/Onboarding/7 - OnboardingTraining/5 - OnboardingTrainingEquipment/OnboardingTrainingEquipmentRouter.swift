//
//  OnboardingTrainingEquipmentRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingTrainingEquipmentRouter {
    func showDevSettingsView()
    func showOnboardingTrainingReviewView(delegate: OnboardingTrainingReviewDelegate)
}

extension OnbRouter: OnboardingTrainingEquipmentRouter { }

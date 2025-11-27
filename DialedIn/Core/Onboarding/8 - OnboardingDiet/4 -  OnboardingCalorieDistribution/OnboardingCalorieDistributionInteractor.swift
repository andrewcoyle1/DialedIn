//
//  OnboardingCalorieDistributionInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingCalorieDistributionInteractor {
    var currentTrainingPlan: TrainingPlan? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingCalorieDistributionInteractor { }

//
//  OnboardingTrainingDaysPerWeekInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingTrainingDaysPerWeekInteractor {
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingTrainingDaysPerWeekInteractor { }

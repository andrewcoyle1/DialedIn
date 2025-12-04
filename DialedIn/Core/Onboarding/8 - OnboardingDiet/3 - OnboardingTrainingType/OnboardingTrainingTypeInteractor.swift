//
//  OnboardingTrainingTypeInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingTrainingTypeInteractor {
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingTrainingTypeInteractor { }

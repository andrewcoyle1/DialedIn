//
//  OnboardingCardioFitnessInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingCardioFitnessInteractor {
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingCardioFitnessInteractor { }

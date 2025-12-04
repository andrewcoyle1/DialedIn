//
//  OnboardingDateOfBirthInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingDateOfBirthInteractor {
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingDateOfBirthInteractor { }

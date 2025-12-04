//
//  OnboardingGenderInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingGenderInteractor {
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingGenderInteractor { }

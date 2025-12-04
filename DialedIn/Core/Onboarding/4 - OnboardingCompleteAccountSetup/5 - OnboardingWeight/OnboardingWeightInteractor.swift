//
//  OnboardingWeightInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingWeightInteractor {
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingWeightInteractor { }

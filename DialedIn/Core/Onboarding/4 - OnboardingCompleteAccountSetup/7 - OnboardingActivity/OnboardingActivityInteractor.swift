//
//  OnboardingActivityInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingActivityInteractor {
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingActivityInteractor { }

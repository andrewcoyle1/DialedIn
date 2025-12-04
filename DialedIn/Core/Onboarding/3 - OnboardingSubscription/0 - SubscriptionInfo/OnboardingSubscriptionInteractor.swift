//
//  OnboardingSubscriptionInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingSubscriptionInteractor {
    func trackEvent(event: LoggableEvent) 
}

extension OnbInteractor: OnboardingSubscriptionInteractor { }

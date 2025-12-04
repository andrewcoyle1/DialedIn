//
//  OnboardingIntroInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingIntroInteractor {
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingIntroInteractor { }

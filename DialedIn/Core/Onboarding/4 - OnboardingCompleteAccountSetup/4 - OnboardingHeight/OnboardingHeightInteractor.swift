//
//  OnboardingHeightInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingHeightInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingHeightInteractor { }

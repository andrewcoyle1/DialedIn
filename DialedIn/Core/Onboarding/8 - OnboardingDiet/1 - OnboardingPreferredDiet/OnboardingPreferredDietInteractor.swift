//
//  OnboardingPreferredDietInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingPreferredDietInteractor {
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingPreferredDietInteractor { }

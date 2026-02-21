//
//  OnboardingIntroInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingIntroInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingIntroInteractor { }

//
//  OnboardingCompletedInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingCompletedInteractor {
    func updateOnboardingStep(step: OnboardingStep) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingCompletedInteractor { }

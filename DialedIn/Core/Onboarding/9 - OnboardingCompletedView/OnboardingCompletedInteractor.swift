//
//  OnboardingCompletedInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingCompletedInteractor {
    func updateOnboardingStep(step: OnboardingStep) async throws
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingCompletedInteractor { }

//
//  OnboardingHealthDataInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingHealthDataInteractor {
    func canRequestHealthDataAuthorisation() async -> Bool
    func requestHealthKitAuthorisation() async throws
    func updateOnboardingStep(step: OnboardingStep) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingHealthDataInteractor { }

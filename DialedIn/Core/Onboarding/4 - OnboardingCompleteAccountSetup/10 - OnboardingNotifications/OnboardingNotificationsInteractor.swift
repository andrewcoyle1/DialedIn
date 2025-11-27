//
//  OnboardingNotificationsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingNotificationsInteractor {
    func requestPushAuthorisation() async throws -> Bool
    func canRequestHealthDataAuthorisation() -> Bool
    func updateOnboardingStep(step: OnboardingStep) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingNotificationsInteractor { }

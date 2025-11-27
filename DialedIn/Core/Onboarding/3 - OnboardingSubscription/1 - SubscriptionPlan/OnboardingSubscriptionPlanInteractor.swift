//
//  OnboardingSubscriptionPlanInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingSubscriptionPlanInteractor {
    var currentUser: UserModel? { get }
    func updateOnboardingStep(step: OnboardingStep) async throws
    func purchase() async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingSubscriptionPlanInteractor { }

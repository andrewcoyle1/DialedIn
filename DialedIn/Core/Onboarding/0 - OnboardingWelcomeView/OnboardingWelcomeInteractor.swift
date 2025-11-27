//
//  OnboardingWelcomeInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingWelcomeInteractor {
    var currentUser: UserModel? { get }
    var onboardingStep: OnboardingStep { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingWelcomeInteractor { }

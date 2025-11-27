//
//  OnboardingCompleteAccountSetupInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingCompleteAccountSetupInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingCompleteAccountSetupInteractor { }

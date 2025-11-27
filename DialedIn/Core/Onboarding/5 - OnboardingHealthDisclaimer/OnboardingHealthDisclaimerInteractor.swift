//
//  OnboardingHealthDisclaimerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

protocol OnboardingHealthDisclaimerInteractor {
    var currentUser: UserModel? { get }
    func updateHealthConsents(disclaimerVersion: String, step: OnboardingStep, privacyVersion: String, acceptedAt: Date) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingHealthDisclaimerInteractor { }

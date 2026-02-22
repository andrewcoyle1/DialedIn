//
//  OnboardingHealthDisclaimerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol OnboardingHealthDisclaimerInteractor: GlobalInteractor {
    func updateHealthConsents(disclaimerVersion: String, privacyVersion: String, acceptedAt: Date) async throws
}

extension CoreInteractor: OnboardingHealthDisclaimerInteractor { }

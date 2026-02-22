//
//  OnboardingCompletedInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingCompletedInteractor: GlobalInteractor {
    func updateDidCompleteOnboarding() async throws
}

extension CoreInteractor: OnboardingCompletedInteractor { }

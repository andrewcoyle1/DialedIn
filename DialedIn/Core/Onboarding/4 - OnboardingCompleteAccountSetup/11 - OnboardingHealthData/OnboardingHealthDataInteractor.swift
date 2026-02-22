//
//  OnboardingHealthDataInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingHealthDataInteractor: GlobalInteractor {
    func canRequestHealthDataAuthorisation() async -> Bool
    func requestHealthKitAuthorisation() async throws
}

extension CoreInteractor: OnboardingHealthDataInteractor { }

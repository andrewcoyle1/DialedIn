//
//  OnboardingExpenditureInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingExpenditureInteractor {
    func saveCompleteAccountSetupProfile(userBuilder: UserModelBuilder, onboardingStep: OnboardingStep) async throws -> UserModel
    func estimateTDEE(user: UserModel?) -> Double
    func updateOnboardingStep(step: OnboardingStep) async throws
    func canRequestNotificationAuthorization() async -> Bool
    func canRequestHealthDataAuthorisation() -> Bool
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingExpenditureInteractor { }

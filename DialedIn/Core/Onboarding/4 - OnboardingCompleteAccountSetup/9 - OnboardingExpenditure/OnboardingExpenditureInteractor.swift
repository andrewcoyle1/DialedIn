//
//  OnboardingExpenditureInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingExpenditureInteractor: Sendable {
    func saveCompleteAccountSetupProfile(userBuilder: UserModelBuilder, onboardingStep: OnboardingStep) async throws -> UserModel
    func estimateTDEE(user: UserModel?) -> Double
    func updateOnboardingStep(step: OnboardingStep) async throws
    func canRequestNotificationAuthorisation() async -> Bool
    func canRequestHealthDataAuthorisation() -> Bool
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingExpenditureInteractor {
}

//
//  OnboardingExpenditureInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingExpenditureInteractor {
    func saveCompleteAccountSetupProfile(userBuilder: UserModelBuilder) async throws -> UserModel
    func estimateTDEE(user: UserModel?) -> Double
    func canRequestNotificationAuthorization() async -> Bool
    func canRequestHealthDataAuthorisation() -> Bool
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingExpenditureInteractor { }

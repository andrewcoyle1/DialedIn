//
//  ExpenditureInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ExpenditureInteractor {
    var currentUser: UserModel? { get }
    func saveUser(user: UserModel, image: PlatformImage?) async throws
    func estimateTDEE(user: UserModel?) -> Double
    func canRequestNotificationAuthorization() async -> Bool
    func canRequestHealthDataAuthorisation() -> Bool
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ExpenditureInteractor { }

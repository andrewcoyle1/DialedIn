//
//  AppInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol AppInteractor: GlobalInteractor {
    var auth: UserAuthInfo? { get }
    var startingModuleId: String { get }
    func schedulePushNotificationsForNextWeek()
    func trackEvent(event: LoggableEvent)
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws
    func syncAllRemoteDataIfLoggedIn() async
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func saveUserFCMToken(token: String) async throws

}

extension CoreInteractor: AppInteractor { }

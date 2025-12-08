//
//  AppInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol AppInteractor {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    var showTabBar: Bool { get }
    func schedulePushNotificationsForNextWeek()
    func trackEvent(event: LoggableEvent)
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws
}

extension RootInteractor: AppInteractor {
}

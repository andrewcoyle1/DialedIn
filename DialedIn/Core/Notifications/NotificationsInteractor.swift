//
//  NotificationsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import UserNotifications

@MainActor
protocol NotificationsInteractor: GlobalInteractor {
    var isAuthorised: UNAuthorizationStatus { get }
    func requestPushAuthorisation() async throws -> Bool
    func canRequestNotificationAuthorisation() async -> Bool
    func removeDeliveredNotifications(ids: [String])
}

extension CoreInteractor: NotificationsInteractor { }

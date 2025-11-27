//
//  NotificationsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import UserNotifications

protocol NotificationsInteractor {
    func getNotificationAuthorisationStatus() async -> UNAuthorizationStatus
    func requestPushAuthorisation() async throws -> Bool
    func getDeliveredNotifications() async -> [UNNotification]
    func removeDeliveredNotification(identifier: String) async
}

extension CoreInteractor: NotificationsInteractor { }

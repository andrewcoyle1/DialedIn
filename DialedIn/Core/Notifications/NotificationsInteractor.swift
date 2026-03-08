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
    var activityNotifications: [ActivityNotificationModel] { get }
    func requestPushAuthorisation() async throws -> Bool
    func canRequestNotificationAuthorisation() async -> Bool
    func removeDeliveredNotifications(ids: [String])
    func checkPushNotificationAuthorisation() async throws -> UNAuthorizationStatus
    func fetchActivityNotifications() async throws
}

extension CoreInteractor: NotificationsInteractor {
    var activityNotifications: [ActivityNotificationModel] {
        activityNotificationManager.notifications
    }

    func fetchActivityNotifications() async throws {
        guard let userId else { return }
        try await activityNotificationManager.fetchNotifications(userId: userId)
    }
}

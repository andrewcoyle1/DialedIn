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
    func markActivityNotificationsRead() async throws
    func deleteActivityNotification(id: String) async throws
    func clearAllDeliveredNotifications()
}

extension CoreInteractor: NotificationsInteractor { }

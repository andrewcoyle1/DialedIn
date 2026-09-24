//
//  NotificationsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import UserNotifications

@MainActor
protocol NotificationsInteractor: FollowInteractor {
    var isAuthorised: UNAuthorizationStatus { get }
    var activityNotifications: [ActivityNotificationModel] { get }
    var incomingFollowRequests: [FollowRequestModel] { get }
    func requestPushAuthorisation() async throws -> Bool
    func canRequestNotificationAuthorisation() async -> Bool
    func removeDeliveredNotifications(ids: [String])
    func checkPushNotificationAuthorisation() async throws -> UNAuthorizationStatus
    func fetchActivityNotifications() async throws
    func markActivityNotificationsRead() async throws
    func deleteActivityNotification(id: String) async throws
    func clearAllDeliveredNotifications()
    func fetchIncomingFollowRequests() async throws
    func respondToFollowRequest(requesterId: String, accept: Bool) async throws
    func getUser(userId: String) async throws -> UserModel
    func updateSocialNotificationPreferences(type: ActivityNotificationModel.ActivityType, isEnabled: Bool) async throws
}

extension CoreInteractor: NotificationsInteractor { }

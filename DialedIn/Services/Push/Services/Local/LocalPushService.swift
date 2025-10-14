//
//  LocalPushService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import Foundation
import UserNotifications

protocol LocalPushService {
    func requestAuthorisation() async throws -> Bool
    func canRequestAuthorisation() async -> Bool
    func schedulePushNotificationsForNextWeek() async throws
    func scheduleNotification(title: String, subtitle: String, triggerDate: Date) async throws
    func getDeliveredNotifications() async -> [UNNotification]
    func removeDeliveredNotification(identifier: String) async
    func getNotificationAuthorizationStatus() async -> UNAuthorizationStatus
}

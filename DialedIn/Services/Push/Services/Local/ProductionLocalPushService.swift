//
//  ProductionLocalPushService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import Foundation
import SwiftfulUtilities
import UserNotifications

struct ProductionLocalPushService: LocalPushService {
    func requestAuthorisation() async throws -> Bool {
        try await LocalNotifications.requestAuthorization()
    }

    func canRequestAuthorisation() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }

    func schedulePushNotificationsForNextWeek() async throws {
        LocalNotifications.removeAllPendingNotifications()
        LocalNotifications.removeAllDeliveredNotifications()

        let calendar = Calendar.current
        let now = Date()

        // Tomorrow
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) {
            try await scheduleNotification(
                title: "Keep up the momentum!",
                subtitle: "Your next workout is just a day away. Ready to crush it tomorrow?",
                triggerDate: tomorrow
            )
        }

        // In 3 days
        if let inThreeDays = calendar.date(byAdding: .day, value: 3, to: now) {
            try await scheduleNotification(
                title: "Stay Consistent",
                subtitle: "It's been a few days since your last session. Let's get moving!",
                triggerDate: inThreeDays
            )
        }

        // In 5 days
        if let inFiveDays = calendar.date(byAdding: .day, value: 5, to: now) {
            try await scheduleNotification(
                title: "Don't Lose Your Streak!",
                subtitle: "Come back for a workout and keep your progress going strong.",
                triggerDate: inFiveDays
            )
        }
    }

    func scheduleNotification(title: String, subtitle: String, triggerDate: Date) async throws {
        let content = AnyNotificationContent(title: title, body: subtitle)
        let trigger = NotificationTriggerOption.date(date: triggerDate, repeats: false)
        try await LocalNotifications.scheduleNotification(content: content, trigger: trigger)
    }
    
    func scheduleNotification(identifier: String, title: String, subtitle: String, triggerDate: Date) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = subtitle
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func getDeliveredNotifications() async -> [UNNotification] {
        await UNUserNotificationCenter.current().deliveredNotifications()
    }
    
    func removeDeliveredNotification(identifier: String) async {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    func removePendingNotifications(withIdentifiers identifiers: [String]) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func getNotificationAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
}

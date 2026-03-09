//
//  ActivityNotificationManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 08/03/2026.
//

import Foundation

@Observable
@MainActor
class ActivityNotificationManager {

    private let service: ActivityNotificationService
    private(set) var notifications: [ActivityNotificationModel] = []
    var pendingBanner: ActivityNotificationModel?

    init(service: ActivityNotificationService) {
        self.service = service
    }

    func fetchNotifications(userId: String) async throws {
        notifications = try await service.fetchNotifications(userId: userId)
    }

    func addNotification(_ notification: ActivityNotificationModel, userId: String) async throws {
        try await service.addNotification(notification, userId: userId)
    }

    func deleteNotification(id: String, userId: String) async throws {
        try await service.deleteNotification(id: id, userId: userId)
        notifications.removeAll { $0.id == id }
    }

    func markAllRead(userId: String) async throws {
        try await service.markAllRead(userId: userId)
        notifications = notifications.map {
            var notification = $0
            notification.isRead = true
            return notification
        }
    }

    func startListening(userId: String) {
        service.startListening(userId: userId) { [weak self] notification in
            guard let self else { return }
            notifications.insert(notification, at: 0)
            pendingBanner = notification
            NotificationCenter.default.post(name: .newActivityNotification, object: notification)
            let id = notification.id
            Task {
                try? await Task.sleep(for: .seconds(4))
                if pendingBanner?.id == id { pendingBanner = nil }
            }
        }
    }

    func stopListening() {
        service.stopListening()
    }
}

extension CoreInteractor {
    var activityNotifications: [ActivityNotificationModel] {
        activityNotificationManager.notifications
    }

    func fetchActivityNotifications() async throws {
        guard let userId else { return }
        try await activityNotificationManager.fetchNotifications(userId: userId)
    }

    func markActivityNotificationsRead() async throws {
        guard let userId else { return }
        try await activityNotificationManager.markAllRead(userId: userId)
    }

    func deleteActivityNotification(id: String) async throws {
        guard let userId else { return }
        try await activityNotificationManager.deleteNotification(id: id, userId: userId)
    }

}

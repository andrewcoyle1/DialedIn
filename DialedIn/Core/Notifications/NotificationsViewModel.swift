//
//  NotificationsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI
import UserNotifications

protocol NotificationsInteractor {
    func getNotificationAuthorisationStatus() async -> UNAuthorizationStatus
    func requestPushAuthorisation() async throws -> Bool
    func getDeliveredNotifications() async -> [UNNotification]
    func removeDeliveredNotification(identifier: String) async
}

extension CoreInteractor: NotificationsInteractor { }

@Observable
@MainActor
class NotificationsViewModel {
    private let interactor: NotificationsInteractor
    
    private(set) var notifications: [UNNotification] = []
    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    private(set) var isLoading: Bool = true
    
    init(
        interactor: NotificationsInteractor
    ) {
        self.interactor = interactor
    }
    
    func loadNotifications() async {
        isLoading = true
        
        // Get authorization status
        authorizationStatus = await interactor.getNotificationAuthorisationStatus()
        
        // Load notifications if authorized
        if authorizationStatus == .authorized {
            notifications = await interactor.getDeliveredNotifications()
        }
        
        isLoading = false
    }
    
    func deleteNotifications(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let notification = notifications[index]
                await interactor.removeDeliveredNotification(identifier: notification.request.identifier)
            }
            notifications.remove(atOffsets: offsets)
        }
    }
    
    func onRequestNotificationsPressed() {
        Task {
            do {
                _ = try await interactor.requestPushAuthorisation()
                await loadNotifications()
            } catch {
                // Handle error silently or show alert
            }
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    func onDismissPressed(onDismiss: () -> Void) {
        onDismiss()
    }
}

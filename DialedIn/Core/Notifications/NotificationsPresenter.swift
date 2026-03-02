//
//  NotificationsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI
import UserNotifications

@Observable
@MainActor
class NotificationsPresenter {
    private let interactor: NotificationsInteractor
    private let router: NotificationsRouter

    private(set) var notifications: [UNNotification] = []
    
    var authorizationStatus: UNAuthorizationStatus {
        interactor.isAuthorised
    }
    
    private(set) var isLoading: Bool = true
    
    init(
        interactor: NotificationsInteractor,
        router: NotificationsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    func loadNotifications() async {
        isLoading = true
                
        try? await Task.sleep(for: .seconds(1))
        
        isLoading = false
    }
    
    func deleteNotifications(at offsets: IndexSet) {
        for index in offsets {
            let notification = notifications[index]
            interactor.removeDeliveredNotifications(ids: [notification.request.identifier])
        }
        notifications.remove(atOffsets: offsets)
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

    func onDismissPressed() {
        router.dismissScreen()
    }
}

extension NotificationsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear

        var eventName: String {
            switch self {
            case .onAppear:     return "NotificationsView_Appear"
            case .onDisappear:  return "NotificationsView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
                
            }
        }
    }
}

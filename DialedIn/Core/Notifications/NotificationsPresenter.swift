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

    var activityNotifications: [ActivityNotificationModel] {
        interactor.activityNotifications
    }

    var authorizationStatus: UNAuthorizationStatus {
        interactor.isAuthorised
    }
    
    private(set) var isLoading: Bool = true

    /// The Social switches. Each writes the moment it flips, like the Account privacy switch, and
    /// reads back from the profile, so a failed write snaps the switch back once the alert shows.
    var isLikesPushEnabled: Bool {
        get { isSocialPushEnabled(.like) }
        set { onSocialPushToggled(.like, isEnabled: newValue) }
    }

    var isCommentsPushEnabled: Bool {
        get { isSocialPushEnabled(.comment) }
        set { onSocialPushToggled(.comment, isEnabled: newValue) }
    }

    var isFollowsPushEnabled: Bool {
        get { isSocialPushEnabled(.follow) }
        set { onSocialPushToggled(.follow, isEnabled: newValue) }
    }

    var isNudgesPushEnabled: Bool {
        get { isSocialPushEnabled(.nudge) }
        set { onSocialPushToggled(.nudge, isEnabled: newValue) }
    }

    private func isSocialPushEnabled(_ type: ActivityNotificationModel.ActivityType) -> Bool {
        interactor.currentUser?.isSocialPushEnabled(for: type) ?? true
    }

    private func onSocialPushToggled(_ type: ActivityNotificationModel.ActivityType, isEnabled: Bool) {
        interactor.trackEvent(event: Event.socialPushToggled(type: type, isEnabled: isEnabled))
        Task {
            do {
                try await interactor.updateSocialNotificationPreferences(type: type, isEnabled: isEnabled)
            } catch {
                router.showAlert(error: error)
            }
        }
    }
    
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
        try? await interactor.fetchActivityNotifications()
        try? await interactor.markActivityNotificationsRead()
        interactor.clearAllDeliveredNotifications()
        isLoading = false
    }
    
    func checkPermissions() async {
        do {
            _ = try await interactor.checkPushNotificationAuthorisation()
        } catch {
            router.showAlert(error: error)
        }
    }
    
    func onRequestNotificationsPressed() {
        Task {
            do {
                _ = try await interactor.requestPushAuthorisation()
                await loadNotifications()
            } catch {
                // Was an empty catch under a comment reading "Handle error silently or show alert".
                // A permission request the user asked for either works or says why — `checkPermissions`
                // above already surfaces its failures the same way.
                router.showAlert(error: error)
            }
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func onNotificationDeleted(_ notification: ActivityNotificationModel) {
        Task {
            try? await interactor.deleteActivityNotification(id: notification.id)
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
        case socialPushToggled(type: ActivityNotificationModel.ActivityType, isEnabled: Bool)

        var eventName: String {
            switch self {
            case .onAppear:     return "NotificationsView_Appear"
            case .onDisappear:  return "NotificationsView_Disappear"
            case .socialPushToggled: return "NotificationsView_SocialPush_Toggle"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .socialPushToggled(let type, let isEnabled):
                return ["type": type.rawValue, "is_enabled": isEnabled]
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

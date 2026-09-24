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
    private let followFlow: FollowFlow

    /// Requests to follow the reader's private profile, answered from the top of the screen.
    var incomingFollowRequests: [FollowRequestModel] {
        interactor.incomingFollowRequests
    }

    var activityNotifications: [ActivityNotificationModel] {
        interactor.activityNotifications
    }

    var authorizationStatus: UNAuthorizationStatus {
        interactor.isAuthorised
    }
    
    private(set) var isLoading: Bool = true

    /// The Social switches. Each writes the moment it flips, like the Account privacy switch, and
    /// reads back from the private settings document, so a failed write snaps the switch back once the alert shows.
    var isLikesPushEnabled: Bool {
        get { isSocialPushEnabled(.like) }
        set { onSocialPushToggled(.like, isEnabled: newValue) }
    }

    var isCommentsPushEnabled: Bool {
        get { isSocialPushEnabled(.comment) }
        set { onSocialPushToggled(.comment, isEnabled: newValue) }
    }

    var isMentionsPushEnabled: Bool {
        get { isSocialPushEnabled(.mention) }
        set { onSocialPushToggled(.mention, isEnabled: newValue) }
    }

    var isFollowsPushEnabled: Bool {
        get { isSocialPushEnabled(.follow) }
        set { onSocialPushToggled(.follow, isEnabled: newValue) }
    }

    var isNudgesPushEnabled: Bool {
        get { isSocialPushEnabled(.nudge) }
        set { onSocialPushToggled(.nudge, isEnabled: newValue) }
    }

    // MARK: - Sharing
    var isSharesPushEnabled: Bool {
        get { isSocialPushEnabled(.share) }
        set { onSocialPushToggled(.share, isEnabled: newValue) }
    }

    private func isSocialPushEnabled(_ type: ActivityNotificationModel.ActivityType) -> Bool {
        interactor.privateUserSettings.isSocialPushEnabled(for: type)
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
        self.followFlow = FollowFlow(interactor: interactor, router: router)
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    func loadNotifications() async {
        isLoading = true
        // Follow requests are live from the user manager's listener, so only activity is fetched here.
        // Background load: an empty list or a stale unread badge is the right fallback, not an alert.
        try? await interactor.fetchActivityNotifications()
        try? await interactor.markActivityNotificationsRead()
        interactor.clearAllDeliveredNotifications()
        isLoading = false
    }
    
    /// Pull-to-refresh re-reads the follow requests too, in case the listener has dropped.
    func onPullToRefresh() async {
        // Silent: the live listener still owns this list; the refresh is only a backstop.
        try? await interactor.fetchIncomingFollowRequests()
        await loadNotifications()
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
            do {
                try await interactor.deleteActivityNotification(id: notification.id)
            } catch {
                interactor.trackEvent(event: Event.deleteNotificationFail(error: error))
                router.showSimpleAlert(title: "Unable to Delete Notification", subtitle: "Please try again.")
            }
        }
    }

    // MARK: Follow back and follow requests

    /// Only a follow row offers a follow back, and never for the reader themselves.
    func showsFollowBack(for notification: ActivityNotificationModel) -> Bool {
        notification.type == .follow && notification.actorId != interactor.currentUser?.userId
    }

    func followBackState(for notification: ActivityNotificationModel) -> FollowState {
        interactor.followState(for: notification.actorId)
    }

    /// The notification does not carry the actor's privacy, so the profile is read when the button
    /// is tapped: whether it follows or requests depends on the account as it is now, not as it was
    /// when they followed.
    func onFollowBackPressed(_ notification: ActivityNotificationModel) {
        interactor.trackEvent(event: Event.followBackPressed)
        Task {
            do {
                let actor = try await interactor.getUser(userId: notification.actorId)
                followFlow.onButtonPressed(user: actor)
            } catch {
                router.showSimpleAlert(title: "Unable to follow user", subtitle: "Please try again.")
            }
        }
    }

    func onAcceptRequestPressed(_ request: FollowRequestModel) {
        respond(to: request, accept: true)
    }

    func onDeclineRequestPressed(_ request: FollowRequestModel) {
        respond(to: request, accept: false)
    }

    private func respond(to request: FollowRequestModel, accept: Bool) {
        interactor.trackEvent(event: Event.followRequestAnswered(accept: accept))
        Task {
            do {
                try await interactor.respondToFollowRequest(requesterId: request.requesterId, accept: accept)
            } catch {
                router.showSimpleAlert(title: "Unable to answer request", subtitle: "Please try again.")
            }
        }
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    /// A like, comment or mention opens the session it is about — a comment or mention with its
    /// thread on top — a follow, an accepted request or a nudge opens the other person's profile, and
    /// a share opens the shared template or program.
    func onNotificationPressed(_ notification: ActivityNotificationModel) {
        interactor.trackEvent(event: Event.notificationPressed(type: notification.type))
        router.showLoadingModal()
        Task {
            do {
                switch notification.type {
                case .follow, .followAccepted, .nudge:
                    let user = try await interactor.getUser(userId: notification.actorId)
                    router.dismissModal()
                    router.showSocialProfileView(delegate: SocialProfileDelegate(user: user))
                case .like, .comment, .mention:
                    let session = try await interactor.fetchWorkoutSession(id: notification.sessionId, authorId: notification.sessionAuthorId)
                    router.dismissModal()
                    let delegate = WorkoutSessionDetailDelegate(workoutSession: session)
                    if notification.type == .like {
                        router.showWorkoutSessionDetailView(delegate: delegate)
                    } else {
                        router.showWorkoutSessionThread(delegate: delegate)
                    }
                case .share:
                    let share = try await interactor.fetchShare(id: notification.shareId ?? "")
                    router.dismissModal()
                    router.showSharedItemView(delegate: SharedItemDelegate(share: share, senderName: notification.actorName))
                }
            } catch {
                router.dismissModal()
                router.showSimpleAlert(title: "Unable to Open", subtitle: "It may have been deleted. Please try again.")
            }
        }
    }
}

extension NotificationsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case socialPushToggled(type: ActivityNotificationModel.ActivityType, isEnabled: Bool)
        case notificationPressed(type: ActivityNotificationModel.ActivityType)
        case followBackPressed
        case followRequestAnswered(accept: Bool)
        case deleteNotificationFail(error: Error)

        var eventName: String {
            switch self {
            case .deleteNotificationFail: return "NotificationsView_DeleteNotification_Fail"
            case .onAppear:     return "NotificationsView_Appear"
            case .onDisappear:  return "NotificationsView_Disappear"
            case .socialPushToggled: return "NotificationsView_SocialPush_Toggle"
            case .notificationPressed: return "NotificationsView_Notification_Pressed"
            case .followBackPressed: return "NotificationsView_FollowBack_Pressed"
            case .followRequestAnswered: return "NotificationsView_FollowRequest_Answered"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .deleteNotificationFail(error: let error): return error.eventParameters
            case .socialPushToggled(let type, let isEnabled):
                return ["type": type.rawValue, "is_enabled": isEnabled]
            case .notificationPressed(let type):
                return ["type": type.rawValue]
            case .followRequestAnswered(let accept):
                return ["accept": accept]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .deleteNotificationFail: return .severe
            default:
                return .analytic
                
            }
        }
    }
}

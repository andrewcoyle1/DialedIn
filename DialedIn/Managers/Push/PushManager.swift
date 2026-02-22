//
//  PushManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import Foundation

@Observable
@MainActor
class PushManager {

    let logManager: LogManager?

    init(logManager: LogManager? = nil) {
        self.logManager = logManager
    }

    func requestAuthorisation() async throws -> Bool {
        let isAuthorised = try await LocalNotifications.requestAuthorization()
        logManager?.addUserProperties(dict: ["push_is_authorised": isAuthorised], isHighPriority: true)
        return isAuthorised
    }

    func canRequestAuthorisation() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }

    func schedulePushNotificationsForNextWeek() {
        LocalNotifications.removeAllPendingNotifications()
        LocalNotifications.removeAllDeliveredNotifications()
        
        Task {
            do {
        
                // Tomorrow
                try await scheduleNotification(
                    title: "Keep up the momentum!",
                    subtitle: "Your next workout is just a day away. Ready to crush it tomorrow?",
                    triggerDate: Date().addingTimeInterval(days: 1)
                )

                // In 3 days
                try await scheduleNotification(
                    title: "Stay Consistent",
                    subtitle: "It's been a few days since your last session. Let's get moving!",
                    triggerDate: Date().addingTimeInterval(days: 3)
                )
                
                // In 5 days
                try await scheduleNotification(
                    title: "Don't Lose Your Streak!",
                    subtitle: "Come back for a workout and keep your progress going strong.",
                    triggerDate: Date().addingTimeInterval(days: 5)
                )
                                
                logManager?.trackEvent(event: Event.weekScheduledSuccess)
            } catch {
                logManager?.trackEvent(event: Event.weekScheduledFail(error: error))
            }
        }
    }
    
    func schedulePushNotification(identifier: String, title: String, subtitle: String, triggerDate: Date, sound: Bool = false, badge: Int? = nil) async throws {
        let content = AnyNotificationContent(id: identifier, title: title, body: subtitle, sound: true, badge: badge)
        let trigger = NotificationTriggerOption.date(date: triggerDate, repeats: false)
        try await LocalNotifications.scheduleNotification(content: content, trigger: trigger)
    }
    
    private func scheduleNotification(title: String, subtitle: String, triggerDate: Date) async throws {
        let content = AnyNotificationContent(title: title, body: subtitle)
        let trigger = NotificationTriggerOption.date(date: triggerDate, repeats: false)
        try await LocalNotifications.scheduleNotification(content: content, trigger: trigger)
    }

    enum Event: LoggableEvent {
        case weekScheduledSuccess
        case weekScheduledFail(error: Error)

        var eventName: String {
            switch self {
            case .weekScheduledSuccess:  return "PushMan_WeekScheduled_Success"
            case .weekScheduledFail:     return "PushMan_WeekScheduled_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .weekScheduledFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .weekScheduledFail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}

extension CoreInteractor {
    
    // MARK: PushManager
    
    func schedulePushNotification(identifier: String, title: String, subtitle: String, triggerDate: Date, sound: Bool, badge: Int?) async throws {
        try await pushManager.schedulePushNotification(identifier: identifier, title: title, subtitle: subtitle, triggerDate: triggerDate, sound: sound, badge: badge)
    }

    func requestPushAuthorization() async throws -> Bool {
        try await pushManager.requestAuthorisation()
    }
    
    func canRequestNotificationAuthorization() async -> Bool {
        await pushManager.canRequestAuthorisation()
    }
    
    func schedulePushNotificationsForNextWeek() {
        pushManager.schedulePushNotificationsForNextWeek()
    }

}

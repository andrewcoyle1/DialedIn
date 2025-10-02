//
//  PushManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import Foundation

@MainActor
@Observable
class PushManager {

    let logManager: LogManager?
    let local: LocalPushService
    init(services: PushServices, logManager: LogManager? = nil) {
        self.local = services.local
        self.logManager = logManager
    }

    func requestAuthorisation() async throws -> Bool {
        let isAuthorised = try await local.requestAuthorisation()
        logManager?.addUserProperties(dict: ["push_is_authorised": isAuthorised], isHighPriority: true)
        return isAuthorised
    }

    func canRequestAuthorisation() async -> Bool {
        await local.canRequestAuthorisation()
    }

    func schedulePushNotificationsForNextWeek() {
        Task {
            do {
                try await local.schedulePushNotificationsForNextWeek()
                logManager?.trackEvent(event: Event.weekScheduledSuccess)
            } catch {
                logManager?.trackEvent(event: Event.weekScheduledFail(error: error))
            }
        }
    }

    func schedulePushNotification(title: String, body: String, date: Date) async throws {
        try await local.scheduleNotification(title: title, subtitle: body, triggerDate: date)
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

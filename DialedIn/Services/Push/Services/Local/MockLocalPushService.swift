//
//  MockLocalPushService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import Foundation
import UserNotifications

struct MockLocalPushService: LocalPushService {

    let delay: Double
    let showError: Bool
    let canRequestAuthorisationTest: Bool

    init(canRequestAuthorisation: Bool = true, delay: Double = 0.0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
        self.canRequestAuthorisationTest = canRequestAuthorisation
    }

    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }

    func requestAuthorisation() async throws -> Bool {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        if !showError {
            return true
        } else {
            return false
        }
    }

    func canRequestAuthorisation() async -> Bool {
        try? await Task.sleep(for: .seconds(delay))
        return self.canRequestAuthorisationTest
    }

    func schedulePushNotificationsForNextWeek() async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }

    func scheduleNotification(title: String, subtitle: String, triggerDate: Date) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func getDeliveredNotifications() async -> [UNNotification] {
        try? await Task.sleep(for: .seconds(delay))
        // Return mock notifications for preview
        return []
    }
    
    func removeDeliveredNotification(identifier: String) async {
        try? await Task.sleep(for: .seconds(delay))
    }
    
    func getNotificationAuthorizationStatus() async -> UNAuthorizationStatus {
        try? await Task.sleep(for: .seconds(delay))
        return canRequestAuthorisationTest ? .notDetermined : .authorized
    }
}

//
//  ProductionLocalPushService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import Foundation
import SwiftfulUtilities

struct ProductionLocalPushService: LocalPushService {
    func requestAuthorisation() async throws -> Bool {
        try await LocalNotifications.requestAuthorization()
    }

    func canRequestAuthorisation() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }
}

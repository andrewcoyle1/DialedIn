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

    let local: LocalPushService
    init(services: PushServices) {
        self.local = services.local
    }

    func requestAuthorisation() async throws -> Bool {
        try await local.requestAuthorisation()
    }

    func canRequestAuthorisation() async -> Bool {
        await local.canRequestAuthorisation()
    }
}

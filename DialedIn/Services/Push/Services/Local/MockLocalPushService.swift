//
//  MockLocalPushService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import Foundation

struct MockLocalPushService: LocalPushService {

    let delay: Double
    let showError: Bool

    init(delay: Double = 0.0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
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
        if !showError {
            return true
        } else {
            return false
        }
    }
}

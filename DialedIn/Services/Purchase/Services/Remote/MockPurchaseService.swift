//
//  MockPurchaseService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct MockPurchaseService: RemotePurchaseService {
    
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
    
    func purchase() async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
}

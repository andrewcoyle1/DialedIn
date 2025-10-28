//
//  MockPurchasePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import Foundation

class MockPurchasePersistence: LocalPurchasePersistence {
    
    var showError: Bool

    init(showError: Bool = false) {
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func markAsPurchased() throws {
        try tryShowError()
    }
}

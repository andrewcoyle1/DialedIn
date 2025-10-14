//
//  PurchaseManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

@MainActor
@Observable
class PurchaseManager {
    
    private let local: LocalPurchasePersistence
    private let remote: RemotePurchaseService
    
    init(services: PurchaseServices) {
        self.remote = services.remote
        self.local = services.local
    }
    
    func purchase() async throws {
        try await remote.purchase()
        try local.markAsPurchased()
    }
}

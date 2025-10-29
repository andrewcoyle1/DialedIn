//
//  MockPurchaseServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockPurchaseServices: PurchaseServices {
    let remote: RemotePurchaseService
    let local: LocalPurchasePersistence
    
    init(delay: Double = 0, showError: Bool = false) {
        self.remote = MockPurchaseService(delay: delay, showError: showError)
        self.local = MockPurchasePersistence(showError: showError)
    }
}

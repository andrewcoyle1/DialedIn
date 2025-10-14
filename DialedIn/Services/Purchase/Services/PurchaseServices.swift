//
//  PurchaseService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

protocol PurchaseServices {
    var remote: RemotePurchaseService { get }
    var local: LocalPurchasePersistence { get }
}

struct MockPurchaseServices: PurchaseServices {
    let remote: RemotePurchaseService
    let local: LocalPurchasePersistence
    
    init(delay: Double = 0, showError: Bool = false) {
        self.remote = MockPurchaseService(delay: delay, showError: showError)
        self.local = MockPurchasePersistence(showError: showError)
    }
}

struct ProductionPurchaseServices: PurchaseServices {
    let remote: RemotePurchaseService
    let local: LocalPurchasePersistence
    
    init() {
        self.remote = FirebasePurchaseService()
        self.local = SwiftPurchasePersistence()
    }
}

//
//  ProductionPurchaseServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionPurchaseServices: PurchaseServices {
    let remote: RemotePurchaseService
    let local: LocalPurchasePersistence
    
    @MainActor
    init() {
        self.remote = FirebasePurchaseService()
        self.local = SwiftPurchasePersistence()
    }
}

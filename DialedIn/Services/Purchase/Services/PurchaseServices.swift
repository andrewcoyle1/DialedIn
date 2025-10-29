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

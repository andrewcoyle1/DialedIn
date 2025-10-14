//
//  LocalPurchasePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

@MainActor
protocol LocalPurchasePersistence {
    func markAsPurchased() throws
}

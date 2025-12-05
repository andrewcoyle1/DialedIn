//
//  EntitlementOption.swift
//  DialedIn
//
//  Created by AndrewCoyle on 11/1/24.
//

enum EntitlementOption: Codable, CaseIterable {
    case yearly
    
    var productId: String {
        switch self {
        case .yearly:
            return "andrewcoyle.DialedIn.yearlySubscription"
        }
    }
    
    static var allProductIds: [String] {
        EntitlementOption.allCases.map({ $0.productId })
    }
}

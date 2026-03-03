//
//  MealItemSourceType.swift
//  DialedIn
//
//  Created by Andrew Coyle on 01/03/2026.
//

enum MealItemSourceType: String, DataSyncModelProtocol, CaseIterable, Sendable {
    
    var id: String { self.rawValue }

    case ingredient
    case recipe
}

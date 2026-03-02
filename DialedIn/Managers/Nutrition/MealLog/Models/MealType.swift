//
//  MealType.swift
//  DialedIn
//
//  Created by Andrew Coyle on 01/03/2026.
//

enum MealType: String, DataSyncModelProtocol, CaseIterable, Sendable {
    
    var id: String { self.rawValue }
    
    case breakfast
    case lunch
    case dinner
    case snack
}

//
//  Laterality.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/02/2026.
//

import Foundation

enum Laterality: String, DataSyncModelProtocol, PickableItem {
    
    var id: String { self.rawValue }
    
    case bilateral
    case unilateral
    case assymetrical
    case unilateralBilateral
    
    var name: String {
        switch self {
        case .bilateral: return "Bilateral"
        case .unilateral: return "Unilateral"
        case .assymetrical: return "Asymmetrical"
        case .unilateralBilateral: return "Unilateral & Bilateral"
        }
    }
    
    var description: String? {
        switch self {
        case .bilateral: return "Both sides of the body work together at the same time."
        case .unilateral: return "Only one side of the body works independently at a time."
        case .assymetrical: return "Both sides work together, but with uneven load or position."
        case .unilateralBilateral: return "Exercises performed with both sides at once, but each limb works independently on its own path."
        }
    }
}

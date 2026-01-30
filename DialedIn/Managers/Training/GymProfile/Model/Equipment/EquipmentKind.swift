//
//  EquipmentKind.swift
//  DialedIn
//
//  Created by Andrew Coyle on 01/27/2026.
//

import Foundation

enum EquipmentKind: String, CaseIterable, Identifiable, Codable, Hashable, Sendable {
    case freeWeight
    case loadableBar
    case fixedWeightBar
    case bands
    case bodyWeight
    case supportEquipment
    case accessoryEquipment
    case loadableAccessoryEquipment
    case cableMachine
    case plateLoadedMachine
    case pinLoadedMachine
    
    var id: String { rawValue }
}

extension EquipmentKind {
    var sectionTitle: String {
        switch self {
        case .freeWeight:
            return "Free Weights"
        case .loadableBar:
            return "Loadable Bars"
        case .fixedWeightBar:
            return "Fixed Weight Bars"
        case .bands:
            return "Bands"
        case .bodyWeight:
            return "Body Weights"
        case .supportEquipment:
            return "Support Equipment"
        case .accessoryEquipment:
            return "Accessory Equipment"
        case .loadableAccessoryEquipment:
            return "Loadable Accessory Equipment"
        case .cableMachine:
            return "Cable Machines"
        case .plateLoadedMachine:
            return "Plate Loaded Machines"
        case .pinLoadedMachine:
            return "Pin Loaded Machines"
        }
    }
}

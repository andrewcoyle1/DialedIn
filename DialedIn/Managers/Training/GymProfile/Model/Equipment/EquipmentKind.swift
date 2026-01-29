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

//
//  EquipmentConformances.swift
//  DialedIn
//
//  Created by Andrew Coyle on 01/27/2026.
//

import Foundation

extension FreeWeights: @MainActor GymEquipmentItem {
    static var kind: EquipmentKind { .freeWeight }
}

extension LoadableBars: @MainActor GymEquipmentItem {
    static var kind: EquipmentKind { .loadableBar }
}

extension FixedWeightBars: @MainActor GymEquipmentItem {
    static var kind: EquipmentKind { .fixedWeightBar }
}

extension Bands: @MainActor GymEquipmentItem {
    static var kind: EquipmentKind { .bands }
}

extension BodyWeights: @MainActor GymEquipmentItem {
    static var kind: EquipmentKind { .bodyWeight }
}

extension SupportEquipment: @MainActor GymEquipmentItem {
    static var kind: EquipmentKind { .supportEquipment }
}

extension AccessoryEquipment: @MainActor GymEquipmentItem {
    static var kind: EquipmentKind { .accessoryEquipment }
}

extension LoadableAccessoryEquipment: @MainActor GymEquipmentItem {
    static var kind: EquipmentKind { .loadableAccessoryEquipment }
}

extension CableMachine: @MainActor GymEquipmentItem {
    static var kind: EquipmentKind { .cableMachine }
}

extension PlateLoadedMachine: @MainActor GymEquipmentItem {
    static var kind: EquipmentKind { .plateLoadedMachine }
}

extension PinLoadedMachine: @MainActor GymEquipmentItem {
    static var kind: EquipmentKind { .pinLoadedMachine }
}

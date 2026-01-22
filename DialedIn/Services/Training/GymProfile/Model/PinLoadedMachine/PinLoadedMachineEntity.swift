//
//  PinLoadedMachineEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@Model
class PinLoadedMachineEntity {
    
    var id: String
    var name: String
    var pinLoadedMachineDescription: String?
    @Relationship(deleteRule: .cascade, inverse: \PinLoadedMachineRangeEntity.pinLoadedMachine) var ranges: [PinLoadedMachineRangeEntity]
    var defaultRangeId: String?
    
    @Relationship var gymProfile: GymProfileEntity?
    
    var isActive: Bool

    init(from model: PinLoadedMachine) {
        self.id = model.id
        self.name = model.name
        self.pinLoadedMachineDescription = model.description
        self.defaultRangeId = model.defaultRangeId
        self.ranges = model.ranges.map { PinLoadedMachineRangeEntity(from: $0) }
        self.isActive = model.isActive
    }

    @MainActor
    func update(from model: PinLoadedMachine) {
        self.id = model.id
        self.name = model.name
        self.pinLoadedMachineDescription = model.description
        self.defaultRangeId = model.defaultRangeId
        self.ranges = syncEntities(
            existing: ranges,
            models: model.ranges,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { PinLoadedMachineRangeEntity(from: $0) }
        )
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> PinLoadedMachine {
        PinLoadedMachine(
            id: self.id,
            name: self.name,
            description: self.pinLoadedMachineDescription,
            ranges: self.ranges.map { $0.toModel() },
            isActive: self.isActive
        )
    }
}

@Model
class PinLoadedMachineRangeEntity {
    var id: String
    var name: String
    
    var minWeight: Double
    var maxWeight: Double
    var increment: Double
    
    var unit: ExerciseWeightUnit
    
    @Relationship var pinLoadedMachine: PinLoadedMachineEntity?
    
    var isActive: Bool
    
    init(from model: PinLoadedMachineRange) {
        self.id = model.id
        self.name = model.name
        self.minWeight = model.minWeight
        self.maxWeight = model.maxWeight
        self.increment = model.increment
        self.unit = model.unit
        self.isActive = model.isActive
    }

    func update(from model: PinLoadedMachineRange) {
        self.id = model.id
        self.name = model.name
        self.minWeight = model.minWeight
        self.maxWeight = model.maxWeight
        self.increment = model.increment
        self.unit = model.unit
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> PinLoadedMachineRange {
        PinLoadedMachineRange(
            id: self.id,
            name: self.name,
            minWeight: self.minWeight,
            maxWeight: self.maxWeight,
            increment: self.increment,
            unit: self.unit,
            isActive: self.isActive
        )
    }
}

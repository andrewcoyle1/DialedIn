//
//  CableMachineEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@Model
class CableMachineEntity {
    
    var id: String
    var name: String
    var imageName: String?
    var cableMachineDescription: String?
    
    @Relationship(deleteRule: .cascade, inverse: \CableMachineRangeEntity.cableMachine) var ranges: [CableMachineRangeEntity]
    var defaultRangeId: String?
    
    @Relationship var gymProfile: GymProfileEntity?
    
    var isActive: Bool
    
    init(from model: CableMachine) {
        self.id = model.id
        self.name = model.name
        self.imageName = model.imageName
        self.cableMachineDescription = model.description
        self.defaultRangeId = model.defaultRangeId
        self.ranges = model.ranges.map { CableMachineRangeEntity(from: $0) }
        self.isActive = model.isActive
    }

    @MainActor
    func update(from model: CableMachine) {
        self.id = model.id
        self.name = model.name
        self.imageName = model.imageName
        self.cableMachineDescription = model.description
        self.defaultRangeId = model.defaultRangeId
        self.ranges = syncEntities(
            existing: ranges,
            models: model.ranges,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { CableMachineRangeEntity(from: $0) }
        )
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> CableMachine {
        CableMachine(
            id: self.id,
            name: self.name,
            imageName: self.imageName,
            description: self.cableMachineDescription,
            ranges: self.ranges.map { $0.toModel() },
            isActive: self.isActive
        )
    }
}

@Model
class CableMachineRangeEntity {
    var id: String
    var name: String
    var minWeight: Double
    var maxWeight: Double
    var increment: Double
    
    var unit: ExerciseWeightUnit
    
    @Relationship var cableMachine: CableMachineEntity?
    
    var isActive: Bool
    
    init(from model: CableMachineRange) {
        self.id = model.id
        self.name = model.name
        self.minWeight = model.minWeight
        self.maxWeight = model.maxWeight
        self.increment = model.increment
        self.unit = model.unit
        self.isActive = model.isActive
    }

    func update(from model: CableMachineRange) {
        self.id = model.id
        self.name = model.name
        self.minWeight = model.minWeight
        self.maxWeight = model.maxWeight
        self.increment = model.increment
        self.unit = model.unit
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> CableMachineRange {
        CableMachineRange(
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

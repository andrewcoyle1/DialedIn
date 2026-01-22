//
//  PlateLoadedMachineEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@Model
class PlateLoadedMachineEntity {
    
    var id: String
    var name: String
    var plateLoadedMachineDescription: String?
    var defaultBaseWeightId: String?
    @Relationship(deleteRule: .cascade, inverse: \PlateLoadedMachineRangeEntity.plateLoadedMachine) var baseWeights: [PlateLoadedMachineRangeEntity]
    
    @Relationship var gymProfile: GymProfileEntity?
    
    var isActive: Bool
    
    init(from model: PlateLoadedMachine) {
        self.id = model.id
        self.name = model.name
        self.plateLoadedMachineDescription = model.description
        self.defaultBaseWeightId = model.defaultBaseWeightId
        self.baseWeights = model.baseWeights.map { PlateLoadedMachineRangeEntity(from: $0) }
        self.isActive = model.isActive
    }

    @MainActor
    func update(from model: PlateLoadedMachine) {
        self.id = model.id
        self.name = model.name
        self.plateLoadedMachineDescription = model.description
        self.defaultBaseWeightId = model.defaultBaseWeightId
        self.baseWeights = syncEntities(
            existing: baseWeights,
            models: model.baseWeights,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { PlateLoadedMachineRangeEntity(from: $0) }
        )
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> PlateLoadedMachine {
        PlateLoadedMachine(
            id: self.id,
            name: self.name,
            description: self.plateLoadedMachineDescription,
            defaultBaseWeightId: self.defaultBaseWeightId,
            baseWeights: self.baseWeights.map { $0.toModel() },
            isActive: self.isActive
        )
    }
}

@Model
class PlateLoadedMachineRangeEntity {
    var id: String
    
    var baseWeight: Double
    
    var unit: ExerciseWeightUnit
    
    @Relationship var plateLoadedMachine: PlateLoadedMachineEntity?
    
    var isActive: Bool
    
    init(from model: PlateLoadedMachineRange) {
        self.id = model.id
        self.baseWeight = model.baseWeight
        self.unit = model.unit
        self.isActive = model.isActive
    }

    func update(from model: PlateLoadedMachineRange) {
        self.id = model.id
        self.baseWeight = model.baseWeight
        self.unit = model.unit
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> PlateLoadedMachineRange {
        PlateLoadedMachineRange(
            id: self.id,
            baseWeight: self.baseWeight,
            unit: self.unit,
            isActive: self.isActive
        )
    }
}

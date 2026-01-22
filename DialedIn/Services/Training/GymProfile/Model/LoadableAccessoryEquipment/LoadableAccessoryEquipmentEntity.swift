//
//  LoadableAccessoryEquipmentEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@Model
class LoadableAccessoryEquipmentEntity {
    
    var id: String
    var name: String
    var loadableAccessoryEquipmentDescription: String?
    var defaultBaseWeightId: String?
    @Relationship(deleteRule: .cascade, inverse: \LoadableAccessoryEquipmentRangeEntity.loadableAccessoryEquipment) var baseWeights: [LoadableAccessoryEquipmentRangeEntity]
    
    @Relationship var gymProfile: GymProfileEntity?
    
    var isActive: Bool
    
    init(from model: LoadableAccessoryEquipment) {
        self.id = model.id
        self.name = model.name
        self.loadableAccessoryEquipmentDescription = model.description
        self.defaultBaseWeightId = model.defaultBaseWeightId
        self.baseWeights = model.baseWeights.map { LoadableAccessoryEquipmentRangeEntity(from: $0) }
        self.isActive = model.isActive
    }

    @MainActor
    func update(from model: LoadableAccessoryEquipment) {
        self.id = model.id
        self.name = model.name
        self.loadableAccessoryEquipmentDescription = model.description
        self.defaultBaseWeightId = model.defaultBaseWeightId
        self.baseWeights = syncEntities(
            existing: baseWeights,
            models: model.baseWeights,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { LoadableAccessoryEquipmentRangeEntity(from: $0) }
        )
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> LoadableAccessoryEquipment {
        LoadableAccessoryEquipment(
            id: self.id,
            name: self.name,
            description: self.loadableAccessoryEquipmentDescription,
            defaultBaseWeightId: self.defaultBaseWeightId,
            baseWeights: self.baseWeights.map { $0.toModel() },
            isActive: self.isActive
        )
    }
}

@Model
class LoadableAccessoryEquipmentRangeEntity {
    var id: String
    
    var baseWeight: Double
    
    var unit: ExerciseWeightUnit
    
    @Relationship var loadableAccessoryEquipment: LoadableAccessoryEquipmentEntity?
    
    var isActive: Bool
    
    init(from model: LoadableAccessoryEquipmentRange) {
        self.id = model.id
        self.baseWeight = model.baseWeight
        self.unit = model.unit
        self.isActive = model.isActive
    }

    func update(from model: LoadableAccessoryEquipmentRange) {
        self.id = model.id
        self.baseWeight = model.baseWeight
        self.unit = model.unit
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> LoadableAccessoryEquipmentRange {
        LoadableAccessoryEquipmentRange(
            id: self.id,
            baseWeight: self.baseWeight,
            unit: self.unit,
            isActive: self.isActive
        )
    }
}

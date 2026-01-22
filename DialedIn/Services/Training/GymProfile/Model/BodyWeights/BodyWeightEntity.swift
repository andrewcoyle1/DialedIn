//
//  BodyWeightEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@Model
class BodyWeightEntity {
    var id: String
    var name: String
    var weightDescription: String?
    
    @Relationship var gymProfile: GymProfileEntity?
    
    @Relationship(deleteRule: .cascade, inverse: \BodyWeightAvailableEntity.bodyWeight) var range: [BodyWeightAvailableEntity]
    
    var isActive: Bool
    
    init(from model: BodyWeights) {
        self.id = model.id
        self.name = model.name
        self.weightDescription = model.description
        self.range = model.range.map { BodyWeightAvailableEntity(from: $0) }
        self.isActive = model.isActive
    }

    @MainActor
    func update(from model: BodyWeights) {
        self.id = model.id
        self.name = model.name
        self.weightDescription = model.description
        self.range = syncEntities(
            existing: range,
            models: model.range,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { BodyWeightAvailableEntity(from: $0) }
        )
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> BodyWeights {
        BodyWeights(
            id: self.id,
            name: self.name,
            description: self.weightDescription,
            range: self.range.map { $0.toModel() },
            isActive: self.isActive
        )
    }
}

@Model
class BodyWeightAvailableEntity {
    var id: String
    var plateColour: String?
    var availableWeights: Double
    var unit: ExerciseWeightUnit
    var isActive: Bool
    
    @Relationship var bodyWeight: BodyWeightEntity?
    
    init(from model: BodyWeightsAvailable) {
        self.id = model.id
        self.plateColour = model.plateColour
        self.availableWeights = model.availableWeights
        self.unit = model.unit
        self.isActive = model.isActive
    }

    func update(from model: BodyWeightsAvailable) {
        self.id = model.id
        self.plateColour = model.plateColour
        self.availableWeights = model.availableWeights
        self.unit = model.unit
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> BodyWeightsAvailable {
        BodyWeightsAvailable(
            id: self.id,
            plateColour: self.plateColour,
            availableWeights: self.availableWeights,
            unit: self.unit,
            isActive: self.isActive
        )
    }
}

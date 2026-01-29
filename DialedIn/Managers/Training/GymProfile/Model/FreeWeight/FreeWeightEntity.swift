//
//  FreeWeightEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@Model
class FreeWeightEntity {
    var id: String
    var name: String
    var imageName: String?
    var weightDescription: String?
    var needsColour: Bool
    @Relationship var gymProfile: GymProfileEntity?
    
    @Relationship(deleteRule: .cascade, inverse: \FreeWeightAvailableEntity.freeWeight) var range: [FreeWeightAvailableEntity]
    
    var isActive: Bool
    
    init(from model: FreeWeights) {
        self.id = model.id
        self.name = model.name
        self.imageName = model.imageName
        self.weightDescription = model.description
        self.needsColour = model.needsColour
        self.range = model.range.map { FreeWeightAvailableEntity(from: $0) }
        self.isActive = model.isActive
    }

    @MainActor
    func update(from model: FreeWeights) {
        self.id = model.id
        self.name = model.name
        self.imageName = model.imageName
        self.weightDescription = model.description
        self.needsColour = model.needsColour
        self.range = syncEntities(
            existing: range,
            models: model.range,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { FreeWeightAvailableEntity(from: $0) }
        )
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> FreeWeights {
        FreeWeights(
            id: self.id,
            name: self.name,
            imageName: self.imageName,
            description: self.weightDescription,
            needsColour: self.needsColour,
            range: self.range.map { $0.toModel() },
            isActive: self.isActive
        )
    }
}

@Model
class FreeWeightAvailableEntity {
    var id: String
    var plateColour: String?
    var availableWeights: Double
    var unit: ExerciseWeightUnit
    var isActive: Bool
    
    @Relationship var freeWeight: FreeWeightEntity?
    
    init(from model: FreeWeightsAvailable) {
        self.id = model.id
        self.plateColour = model.plateColour
        self.availableWeights = model.availableWeights
        self.unit = model.unit
        self.isActive = model.isActive
    }

    func update(from model: FreeWeightsAvailable) {
        self.id = model.id
        self.plateColour = model.plateColour
        self.availableWeights = model.availableWeights
        self.unit = model.unit
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> FreeWeightsAvailable {
        FreeWeightsAvailable(
            id: self.id,
            plateColour: self.plateColour,
            availableWeights: self.availableWeights,
            unit: self.unit,
            isActive: self.isActive
        )
    }
}

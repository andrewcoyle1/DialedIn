//
//  FixedWeightBarEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@Model
class FixedWeightBarEntity {
    var id: String
    var name: String
    var fixedWeightBarDescription: String?
    @Relationship(deleteRule: .cascade, inverse: \FixedWeightBarBaseWeightEntity.fixedWeightBar) var baseWeights: [FixedWeightBarBaseWeightEntity]
    var defaultBaseWeightId: String?
    
    @Relationship var gymProfile: GymProfileEntity?

    var isActive: Bool
    
    init(from model: FixedWeightBars) {
        self.id = model.id
        self.name = model.name
        self.fixedWeightBarDescription = model.description
        self.defaultBaseWeightId = model.defaultBaseWeightId
        self.baseWeights = model.baseWeights.map { FixedWeightBarBaseWeightEntity(from: $0) }
        self.isActive = model.isActive
    }

    @MainActor
    func update(from model: FixedWeightBars) {
        self.id = model.id
        self.name = model.name
        self.fixedWeightBarDescription = model.description
        self.defaultBaseWeightId = model.defaultBaseWeightId
        self.baseWeights = syncEntities(
            existing: baseWeights,
            models: model.baseWeights,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { FixedWeightBarBaseWeightEntity(from: $0) }
        )
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> FixedWeightBars {
        FixedWeightBars(
            id: self.id,
            name: self.name,
            description: self.fixedWeightBarDescription,
            baseWeights: self.baseWeights.map { $0.toModel() },
            isActive: self.isActive
        )
    }
}

@Model
class FixedWeightBarBaseWeightEntity {
    var id: String
    var baseWeight: Double
    var unit: ExerciseWeightUnit
    var isActive: Bool
    
    @Relationship var fixedWeightBar: FixedWeightBarEntity?
    
    init(from model: FixedWeightBarsBaseWeight) {
        self.id = model.id
        self.baseWeight = model.baseWeight
        self.unit = model.unit
        self.isActive = model.isActive
    }

    func update(from model: FixedWeightBarsBaseWeight) {
        self.id = model.id
        self.baseWeight = model.baseWeight
        self.unit = model.unit
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> FixedWeightBarsBaseWeight {
        FixedWeightBarsBaseWeight(
            id: self.id,
            baseWeight: self.baseWeight,
            unit: self.unit,
            isActive: self.isActive
        )
    }
}

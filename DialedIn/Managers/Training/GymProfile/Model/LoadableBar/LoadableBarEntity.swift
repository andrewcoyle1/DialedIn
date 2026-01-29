//
//  LoadableBarEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@Model
class LoadableBarEntity {
    var id: String
    var name: String
    var imageName: String?
    var loadableBarDescription: String?
    @Relationship(deleteRule: .cascade, inverse: \LoadableBarBaseWeightEntity.loadableBar) var baseWeights: [LoadableBarBaseWeightEntity]
    var defaultBaseWeightId: String?
    
    @Relationship var gymProfile: GymProfileEntity?

    var isActive: Bool
    
    init(from model: LoadableBars) {
        self.id = model.id
        self.name = model.name
        self.imageName = model.imageName
        self.loadableBarDescription = model.description
        self.defaultBaseWeightId = model.defaultBaseWeightId
        self.baseWeights = model.baseWeights.map { LoadableBarBaseWeightEntity(from: $0) }
        self.isActive = model.isActive
    }

    @MainActor
    func update(from model: LoadableBars) {
        self.id = model.id
        self.name = model.name
        self.imageName = model.imageName
        self.loadableBarDescription = model.description
        self.defaultBaseWeightId = model.defaultBaseWeightId
        self.baseWeights = syncEntities(
            existing: baseWeights,
            models: model.baseWeights,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { LoadableBarBaseWeightEntity(from: $0) }
        )
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> LoadableBars {
        LoadableBars(
            id: self.id,
            name: self.name,
            imageName: self.imageName,
            description: self.loadableBarDescription,
            baseWeights: self.baseWeights.map { $0.toModel() },
            isActive: self.isActive
        )
    }
}

@Model
class LoadableBarBaseWeightEntity {
    var id: String
    var baseWeight: Double
    var unit: ExerciseWeightUnit
    var isActive: Bool
    
    @Relationship var loadableBar: LoadableBarEntity?
    
    init(from model: LoadableBarsBaseWeight) {
        self.id = model.id
        self.baseWeight = model.baseWeight
        self.unit = model.unit
        self.isActive = model.isActive
    }

    func update(from model: LoadableBarsBaseWeight) {
        self.id = model.id
        self.baseWeight = model.baseWeight
        self.unit = model.unit
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> LoadableBarsBaseWeight {
        LoadableBarsBaseWeight(
            id: self.id,
            baseWeight: self.baseWeight,
            unit: self.unit,
            isActive: self.isActive
        )
    }
}

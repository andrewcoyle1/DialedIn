//
//  BandsEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@Model
class BandsEntity {
    var id: String
    var name: String
    var imageName: String?
    var weightDescription: String?
    
    @Relationship var gymProfile: GymProfileEntity?
    
    @Relationship(deleteRule: .cascade, inverse: \BandsAvailableEntity.bands) var range: [BandsAvailableEntity]
    
    var isActive: Bool
    
    init(from model: Bands) {
        self.id = model.id
        self.name = model.name
        self.imageName = model.imageName
        self.weightDescription = model.description
        self.range = model.range.map { BandsAvailableEntity(from: $0) }
        self.isActive = model.isActive
    }

    @MainActor
    func update(from model: Bands) {
        self.id = model.id
        self.name = model.name
        self.imageName = model.imageName
        self.weightDescription = model.description
        self.range = syncEntities(
            existing: range,
            models: model.range,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { BandsAvailableEntity(from: $0) }
        )
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> Bands {
        Bands(
            id: self.id,
            name: self.name,
            imageName: self.imageName,
            description: self.weightDescription,
            range: self.range.map { $0.toModel() },
            isActive: self.isActive
        )
    }
}

@Model
class BandsAvailableEntity {
    var id: String
    var name: String
    var bandColour: String
    var availableResistance: Double
    var unit: ExerciseWeightUnit
    var isActive: Bool
    
    @Relationship var bands: BandsEntity?
    
    init(from model: BandsAvailable) {
        self.id = model.id
        self.name = model.name
        self.bandColour = model.bandColour
        self.availableResistance = model.availableResistance
        self.unit = model.unit
        self.isActive = model.isActive
    }

    func update(from model: BandsAvailable) {
        self.id = model.id
        self.name = model.name
        self.bandColour = model.bandColour
        self.availableResistance = model.availableResistance
        self.unit = model.unit
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> BandsAvailable {
        BandsAvailable(
            id: self.id,
            name: self.name,
            bandColour: self.bandColour,
            availableResistance: self.availableResistance,
            unit: self.unit,
            isActive: self.isActive
        )
    }
}

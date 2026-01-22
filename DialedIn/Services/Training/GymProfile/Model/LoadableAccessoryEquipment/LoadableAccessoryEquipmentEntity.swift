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
    var baseWeight: Double
    var unit: ExerciseWeightUnit
    
    @Relationship var gymProfile: GymProfileEntity?
    
    var isActive: Bool
    
    init(from model: LoadableAccessoryEquipment) {
        self.id = model.id
        self.name = model.name
        self.loadableAccessoryEquipmentDescription = model.description
        self.baseWeight = model.baseWeight
        self.unit = model.unit
        self.isActive = model.isActive
    }

    @MainActor
    func update(from model: LoadableAccessoryEquipment) {
        self.id = model.id
        self.name = model.name
        self.loadableAccessoryEquipmentDescription = model.description
        self.baseWeight = model.baseWeight
        self.unit = model.unit
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> LoadableAccessoryEquipment {
        LoadableAccessoryEquipment(
            id: self.id,
            name: self.name,
            description: self.loadableAccessoryEquipmentDescription,
            baseWeight: self.baseWeight,
            unit: self.unit,
            isActive: self.isActive
        )
    }
}

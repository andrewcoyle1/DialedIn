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
    var imageName: String?
    var plateLoadedMachineDescription: String?
    var baseWeight: Double
    var unit: ExerciseWeightUnit
    @Relationship var gymProfile: GymProfileEntity?
    
    var isActive: Bool
    
    init(from model: PlateLoadedMachine) {
        self.id = model.id
        self.name = model.name
        self.imageName = model.imageName
        self.plateLoadedMachineDescription = model.description
        self.baseWeight = model.baseWeight
        self.unit = model.unit
        self.isActive = model.isActive
    }

    @MainActor
    func update(from model: PlateLoadedMachine) {
        self.id = model.id
        self.name = model.name
        self.imageName = model.imageName
        self.plateLoadedMachineDescription = model.description
        self.baseWeight = model.baseWeight
        self.unit = model.unit
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> PlateLoadedMachine {
        PlateLoadedMachine(
            id: self.id,
            name: self.name,
            imageName: self.imageName,
            description: self.plateLoadedMachineDescription,
            baseWeight: self.baseWeight,
            unit: self.unit,
            isActive: self.isActive
        )
    }
}

//
//  AccessoryEquipmentEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@Model
class AccessoryEquipmentEntity {
    var id: String
    var name: String
    var accessoryEquipmentDescription: String?
    
    @Relationship var gymProfile: GymProfileEntity?

    var isActive: Bool
    
    init(from model: AccessoryEquipment) {
        self.id = model.id
        self.name = model.name
        self.accessoryEquipmentDescription = model.description
        self.isActive = model.isActive
    }

    func update(from model: AccessoryEquipment) {
        self.id = model.id
        self.name = model.name
        self.accessoryEquipmentDescription = model.description
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> AccessoryEquipment {
        AccessoryEquipment(
            id: id,
            name: name,
            description: accessoryEquipmentDescription,
            isActive: isActive
        )
    }
}

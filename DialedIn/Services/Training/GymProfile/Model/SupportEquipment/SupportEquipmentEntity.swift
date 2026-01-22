//
//  SupportEquipmentEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@Model
class SupportEquipmentEntity {
    var id: String
    var name: String
    var supportEquipmentDescription: String?
    
    @Relationship var gymProfile: GymProfileEntity?

    var isActive: Bool
    
    init(from model: SupportEquipment) {
        self.id = model.id
        self.name = model.name
        self.supportEquipmentDescription = model.description
        self.isActive = model.isActive
    }

    func update(from model: SupportEquipment) {
        self.id = model.id
        self.name = model.name
        self.supportEquipmentDescription = model.description
        self.isActive = model.isActive
    }
    
    @MainActor
    func toModel() -> SupportEquipment {
        SupportEquipment(
            id: id,
            name: name,
            description: supportEquipmentDescription,
            isActive: isActive
        )
    }
}

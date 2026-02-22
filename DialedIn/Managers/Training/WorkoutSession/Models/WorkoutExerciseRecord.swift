//
//  WorkoutExerciseRecord.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/09/2025.
//

import Foundation

struct WorkoutExerciseRecord: Codable {
    let id: String
    let sessionId: String
    let authorId: String
    let templateId: String
    let name: String
    let trackingMode: TrackingMode
    let index: Int
    let notes: String?
    let imageName: String?
    let order: Int
    let chosenResistanceEquipment: [EquipmentRef]?
    let chosenSupportEquipment: [EquipmentRef]?

    init(
        id: String,
        sessionId: String,
        authorId: String,
        templateId: String,
        name: String,
        trackingMode: TrackingMode,
        index: Int,
        notes: String?,
        imageName: String?,
        order: Int,
        chosenResistanceEquipment: [EquipmentRef]? = nil,
        chosenSupportEquipment: [EquipmentRef]? = nil
    ) {
        self.id = id
        self.sessionId = sessionId
        self.authorId = authorId
        self.templateId = templateId
        self.name = name
        self.trackingMode = trackingMode
        self.index = index
        self.notes = notes
        self.imageName = imageName
        self.order = order
        self.chosenResistanceEquipment = chosenResistanceEquipment
        self.chosenSupportEquipment = chosenSupportEquipment
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case authorId = "author_id"
        case templateId = "template_id"
        case name
        case trackingMode = "tracking_mode"
        case index
        case notes
        case imageName = "image_name"
        case order
        case chosenResistanceEquipment = "chosen_resistance_equipment"
        case chosenSupportEquipment = "chosen_support_equipment"
    }
}

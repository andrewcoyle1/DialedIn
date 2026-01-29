//
//  ExerciseModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/01/2026.
//

import Foundation

struct ExerciseModel: Identifiable, Codable {
    var id: String
    var authorId: String
    var name: String
    var trackableMetrics: [TrackableExerciseMetric]
    var type: ExerciseType
    var laterality: Laterality
    
    var muscleGroups: [Muscles: Bool]
    
    var isBodyweight: Bool
    var resistanceEquipment: [EquipmentRef]
    var supportEquipment: [EquipmentRef]
    
    var rangeOfMotion: Int
    var stability: Int
    var bodyWeightContribution: Double
    var alternateNames: [String]
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case name
        case trackableMetrics = "trackable_metrics"
        case type
        case laterality
        case muscleGroups = "muscle_groups"
        case isBodyweight = "is_bodyweight"
        case resistanceEquipment = "resistance_equipment"
        case supportEquipment = "support_equipment"
        case rangeOfMotion = "range_of_motion"
        case stability = "stability"
        case bodyWeightContribution = "body_weight_contribution"
        case alternateNames = "alternate_names"
        case description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        authorId = try container.decode(String.self, forKey: .authorId)
        name = try container.decode(String.self, forKey: .name)
        trackableMetrics = try container.decode([TrackableExerciseMetric].self, forKey: .trackableMetrics)
        type = try container.decode(ExerciseType.self, forKey: .type)
        laterality = try container.decode(Laterality.self, forKey: .laterality)
        muscleGroups = try container.decode([Muscles: Bool].self, forKey: .muscleGroups)
        isBodyweight = try container.decode(Bool.self, forKey: .isBodyweight)
        
        if let decodedResistance = try? container.decode([EquipmentRef].self, forKey: .resistanceEquipment) {
            resistanceEquipment = decodedResistance
        } else {
            let legacyResistance = (try? container.decode([String].self, forKey: .resistanceEquipment)) ?? []
            resistanceEquipment = legacyResistance.map { EquipmentRef(kind: .freeWeight, id: $0) }
        }
        
        if let decodedSupport = try? container.decode([EquipmentRef].self, forKey: .supportEquipment) {
            supportEquipment = decodedSupport
        } else {
            let legacySupport = (try? container.decode([String].self, forKey: .supportEquipment)) ?? []
            supportEquipment = legacySupport.map { EquipmentRef(kind: .supportEquipment, id: $0) }
        }
        
        rangeOfMotion = try container.decode(Int.self, forKey: .rangeOfMotion)
        stability = try container.decode(Int.self, forKey: .stability)
        bodyWeightContribution = try container.decode(Double.self, forKey: .bodyWeightContribution)
        alternateNames = try container.decode([String].self, forKey: .alternateNames)
        description = try container.decode(String.self, forKey: .description)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(authorId, forKey: .authorId)
        try container.encode(name, forKey: .name)
        try container.encode(trackableMetrics, forKey: .trackableMetrics)
        try container.encode(type, forKey: .type)
        try container.encode(laterality, forKey: .laterality)
        try container.encode(muscleGroups, forKey: .muscleGroups)
        try container.encode(isBodyweight, forKey: .isBodyweight)
        try container.encode(resistanceEquipment, forKey: .resistanceEquipment)
        try container.encode(supportEquipment, forKey: .supportEquipment)
        try container.encode(rangeOfMotion, forKey: .rangeOfMotion)
        try container.encode(stability, forKey: .stability)
        try container.encode(bodyWeightContribution, forKey: .bodyWeightContribution)
        try container.encode(alternateNames, forKey: .alternateNames)
        try container.encode(description, forKey: .description)
    }
}

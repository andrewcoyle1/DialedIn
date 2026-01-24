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
    var resistanceEquipment: [String]
    var supportEquipment: [String]
    
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
}

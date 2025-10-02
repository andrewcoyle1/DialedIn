//
//  WorkoutSessionRecord.swift
//  DialedIn
//
//  Created by AI Assistant on 28/09/2025.
//

import Foundation

struct WorkoutSessionRecord: Codable {
    let id: String
    let authorId: String
    let name: String
    let workoutTemplateId: String?
    let dateCreated: Date
    let dateModified: Date
    let endedAt: Date?
    let notes: String?
    let totalSets: Int
    let totalVolume: Double
    let totalExercises: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case name
        case workoutTemplateId = "workout_template_id"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case endedAt = "ended_at"
        case notes
        case totalSets = "total_sets"
        case totalVolume = "total_volume"
        case totalExercises = "total_exercises"
    }
}

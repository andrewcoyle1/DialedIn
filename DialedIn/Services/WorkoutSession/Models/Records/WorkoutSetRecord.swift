//
//  WorkoutSetRecord.swift
//  DialedIn
//
//  Created by AI Assistant on 28/09/2025.
//

import Foundation

struct WorkoutSetRecord: Codable {
    let id: String
    let sessionId: String
    let exerciseId: String
    let authorId: String
    let setIndex: Int
    let reps: Int?
    let weightKg: Double?
    let durationSec: Int?
    let distanceMeters: Double?
    let rpe: Double?
    let isWarmup: Bool
    let completedAt: Date?
    let dateCreated: Date
    let templateId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case exerciseId = "exercise_id"
        case authorId = "author_id"
        case setIndex = "set_index"
        case reps
        case weightKg = "weight_kg"
        case durationSec = "duration_sec"
        case distanceMeters = "distance_meters"
        case rpe
        case isWarmup
        case completedAt = "completed_at"
        case dateCreated = "date_created"
        case templateId = "template_id"
    }
}


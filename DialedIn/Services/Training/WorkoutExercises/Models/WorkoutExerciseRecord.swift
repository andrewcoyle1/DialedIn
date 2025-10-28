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
    }
}

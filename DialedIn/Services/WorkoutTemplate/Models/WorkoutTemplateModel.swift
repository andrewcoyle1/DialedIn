//
//  WorkoutTemplate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import Foundation
import IdentifiableByString

struct WorkoutTemplateModel: Identifiable, Codable, StringIdentifiable, Hashable {
    var id: String {
        workoutId
    }
    
    let workoutId: String
    let authorId: String?
    let name: String
    let description: String?
    var notes: String?
    private(set) var imageURL: String?
    let dateCreated: Date
    let dateModified: Date?
    var exercises: [ExerciseTemplateModel]
    let clickCount: Int?
    
    init(
        id: String,
        authorId: String,
        name: String,
        description: String? = nil,
        notes: String? = nil,
        imageURL: String? = nil,
        dateCreated: Date,
        dateModified: Date?,
        exercises: [ExerciseTemplateModel] = [],
        clickCount: Int? = 0
    ) {
        self.workoutId = id
        self.authorId = authorId
        self.name = name
        self.description = description
        self.notes = notes
        self.imageURL = imageURL
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.exercises = exercises
        self.clickCount = clickCount
    }
    
    mutating func updateImageURL(imageUrl: String) {
        self.imageURL = imageUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case workoutId = "workout_id"
        case authorId = "author_id"
        case name = "name"
        case description = "description"
        case notes = "notes"
        case imageURL = "image_url"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case exercises = "exercises"
        case clickCount = "click_count"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "workout_\(CodingKeys.workoutId.rawValue)": workoutId,
            "workout_\(CodingKeys.authorId.rawValue)": authorId,
            "workout_\(CodingKeys.name.rawValue)": name,
            "workout_\(CodingKeys.description.rawValue)": description,
            "workout_\(CodingKeys.notes.rawValue)": notes,
            "workout_\(CodingKeys.imageURL.rawValue)": imageURL,
            "workout_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "workout_\(CodingKeys.dateModified.rawValue)": dateModified,
            "workout_\(CodingKeys.exercises.rawValue)": exercises.map { $0.exerciseId },
            "workout_\(CodingKeys.clickCount.rawValue)": clickCount
        ]
        return dict.compactMapValues { $0 }
    }
    
    static func newWorkoutTemplate(
        name: String,
        authorId: String,
        description: String? = nil,
        notes: String? = nil,
        imageURL: String? = nil,
        exercises: [ExerciseTemplateModel] = [],
        clickCount: Int? = 0
    ) -> Self {
        WorkoutTemplateModel(
            id: UUID().uuidString,
            authorId: authorId,
            name: name,
            description: description,
            notes: notes,
            imageURL: imageURL,
            dateCreated: .now,
            dateModified: .now,
            exercises: exercises,
            clickCount: clickCount
        )
    }
    
    static var mock: WorkoutTemplateModel {
        mocks[0]
    }
    
    static var mocks: [WorkoutTemplateModel] {
        [
            
        WorkoutTemplateModel(
            id: "workout1",
            authorId: "user1",
            name: "Full Body Strength",
            description: "A balanced full body workout for all levels.",
            notes: "Focus on form. Rest 60s between sets.",
            imageURL: Constants.randomImage,
            dateCreated: Date(timeIntervalSinceNow: -86400 * 7),
            dateModified: Date(timeIntervalSinceNow: -86400 * 2),
            exercises: [
                
            ]
        ),
        WorkoutTemplateModel(
            id: "workout2",
            authorId: "user2",
            name: "Push Day",
            description: "Chest, shoulders, and triceps focus.",
            notes: nil,
            imageURL: nil,
            dateCreated: Date(timeIntervalSinceNow: -86400 * 14),
            dateModified: nil,
            exercises: [
                
            ]
        ),
        WorkoutTemplateModel(
            id: "workout3",
            authorId: "user3",
            name: "Leg Day",
            description: "Lower body hypertrophy.",
            notes: "Warm up thoroughly.",
            imageURL: Constants.randomImage,
            dateCreated: Date(timeIntervalSinceNow: -86400 * 3),
            dateModified: Date(timeIntervalSinceNow: -86400),
            exercises: [
                
            ]
        )
        ]
    }
}

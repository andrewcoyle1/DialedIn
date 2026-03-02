//
//  WorkoutTemplate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import Foundation

struct WorkoutTemplateModel: DataSyncModelProtocol {
    var id: String {
        workoutId
    }
    
    let workoutId: String
    let authorId: String
    var name: String
    let description: String?
    private(set) var imageURL: String?
    let dateCreated: Date
    let dateModified: Date
    var exercises: [WorkoutTemplateExercise]
    
    init(
        id: String = UUID().uuidString,
        authorId: String,
        name: String,
        description: String? = nil,
        imageURL: String? = nil,
        dateCreated: Date = .now,
        dateModified: Date = .now,
        exercises: [WorkoutTemplateExercise] = [],
    ) {
        self.workoutId = id
        self.authorId = authorId
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.exercises = exercises
    }
    
    mutating func updateImageURL(imageUrl: String) {
        self.imageURL = imageUrl
    }
    
    mutating func updateDateModified(dateModified: Date) {
        self = WorkoutTemplateModel(
            id: workoutId,
            authorId: authorId,
            name: name,
            description: description,
            imageURL: imageURL,
            dateCreated: dateCreated,
            dateModified: dateModified,
            exercises: exercises,
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case workoutId = "workout_id"
        case authorId = "author_id"
        case name = "name"
        case description = "description"
        case imageURL = "image_url"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case exercises = "exercises"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "workout_\(CodingKeys.workoutId.rawValue)": workoutId,
            "workout_\(CodingKeys.authorId.rawValue)": authorId,
            "workout_\(CodingKeys.name.rawValue)": name,
            "workout_\(CodingKeys.description.rawValue)": description,
            "workout_\(CodingKeys.imageURL.rawValue)": imageURL,
            "workout_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "workout_\(CodingKeys.dateModified.rawValue)": dateModified,
            "workout_\(CodingKeys.exercises.rawValue)": exercises.map { $0.id },
        ]
        return dict.compactMapValues { $0 }
    }
    
    static func newWorkoutTemplate(
        name: String,
        authorId: String,
        description: String? = nil,
        imageURL: String? = nil,
        exercises: [WorkoutTemplateExercise] = []
    ) -> Self {
        WorkoutTemplateModel(
            id: UUID().uuidString,
            authorId: authorId,
            name: name,
            description: description,
            imageURL: imageURL,
            dateCreated: .now,
            dateModified: .now,
            exercises: exercises
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
            imageURL: Constants.randomImage,
            dateCreated: Date(timeIntervalSinceNow: -86400 * 7),
            dateModified: Date(timeIntervalSinceNow: -86400 * 2),
            exercises: WorkoutTemplateExercise.mocks
        ),
        WorkoutTemplateModel(
            id: "workout2",
            authorId: "user2",
            name: "Push Day",
            description: "Chest, shoulders, and triceps focus.",
            imageURL: nil,
            dateCreated: Date(timeIntervalSinceNow: -86400 * 14),
            dateModified: Date(),
            exercises: WorkoutTemplateExercise.mocks
        ),
        WorkoutTemplateModel(
            id: "workout3",
            authorId: "user3",
            name: "Leg Day",
            description: "Lower body hypertrophy.",
            imageURL: Constants.randomImage,
            dateCreated: Date(timeIntervalSinceNow: -86400 * 3),
            dateModified: Date(timeIntervalSinceNow: -86400),
            exercises: WorkoutTemplateExercise.mocks
        )
        ]
    }
}

extension WorkoutTemplateModel: Hashable {
    nonisolated static func == (lhs: WorkoutTemplateModel, rhs: WorkoutTemplateModel) -> Bool {
        lhs.workoutId == rhs.workoutId
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(workoutId)
    }
}

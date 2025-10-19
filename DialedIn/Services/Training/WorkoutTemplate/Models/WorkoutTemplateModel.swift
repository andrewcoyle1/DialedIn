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
    private(set) var imageURL: String?
    let isSystemWorkout: Bool
    let dateCreated: Date
    let dateModified: Date
    var exercises: [ExerciseTemplateModel]
    let clickCount: Int?
    let bookmarkCount: Int?
    let favouriteCount: Int?
    
    init(
        id: String,
        authorId: String,
        name: String,
        description: String? = nil,
        imageURL: String? = nil,
        isSystemWorkout: Bool = false,
        dateCreated: Date,
        dateModified: Date,
        exercises: [ExerciseTemplateModel] = [],
        clickCount: Int? = 0,
        bookmarkCount: Int? = 0,
        favouriteCount: Int? = 0
    ) {
        self.workoutId = id
        self.authorId = authorId
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.isSystemWorkout = isSystemWorkout
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.exercises = exercises
        self.clickCount = clickCount
        self.bookmarkCount = bookmarkCount
        self.favouriteCount = favouriteCount
    }
    
    mutating func updateImageURL(imageUrl: String) {
        self.imageURL = imageUrl
    }
    
    mutating func updateDateModified(dateModified: Date) {
        self = WorkoutTemplateModel(
            id: workoutId,
            authorId: authorId ?? "",
            name: name,
            description: description,
            imageURL: imageURL,
            dateCreated: dateCreated,
            dateModified: dateModified,
            exercises: exercises,
            clickCount: clickCount,
            bookmarkCount: bookmarkCount,
            favouriteCount: favouriteCount
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case workoutId = "workout_id"
        case authorId = "author_id"
        case name = "name"
        case description = "description"
        case imageURL = "image_url"
        case isSystemWorkout = "is_system_workout"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case exercises = "exercises"
        case clickCount = "click_count"
        case bookmarkCount = "bookmark_count"
        case favouriteCount = "favourite_count"
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
            "workout_\(CodingKeys.exercises.rawValue)": exercises.map { $0.exerciseId },
            "workout_\(CodingKeys.clickCount.rawValue)": clickCount,
            "workout_\(CodingKeys.bookmarkCount.rawValue)": bookmarkCount,
            "workout_\(CodingKeys.favouriteCount.rawValue)": favouriteCount
        ]
        return dict.compactMapValues { $0 }
    }
    
    static func newWorkoutTemplate(
        name: String,
        authorId: String,
        description: String? = nil,
        imageURL: String? = nil,
        isSystemWorkout: Bool = false,
        exercises: [ExerciseTemplateModel] = [],
        clickCount: Int? = 0,
        bookmarkCount: Int? = 0,
        favouriteCount: Int? = 0
    ) -> Self {
        WorkoutTemplateModel(
            id: UUID().uuidString,
            authorId: authorId,
            name: name,
            description: description,
            imageURL: imageURL,
            isSystemWorkout: isSystemWorkout,
            dateCreated: .now,
            dateModified: .now,
            exercises: exercises,
            clickCount: clickCount,
            bookmarkCount: bookmarkCount,
            favouriteCount: favouriteCount
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
            exercises: ExerciseTemplateModel.mocks,
            bookmarkCount: 12,
            favouriteCount: 3
        ),
        WorkoutTemplateModel(
            id: "workout2",
            authorId: "user2",
            name: "Push Day",
            description: "Chest, shoulders, and triceps focus.",
            imageURL: nil,
            dateCreated: Date(timeIntervalSinceNow: -86400 * 14),
            dateModified: Date(),
            exercises: ExerciseTemplateModel.mocks,
            bookmarkCount: 18,
            favouriteCount: 1
        ),
        WorkoutTemplateModel(
            id: "workout3",
            authorId: "user3",
            name: "Leg Day",
            description: "Lower body hypertrophy.",
            imageURL: Constants.randomImage,
            dateCreated: Date(timeIntervalSinceNow: -86400 * 3),
            dateModified: Date(timeIntervalSinceNow: -86400),
            exercises: ExerciseTemplateModel.mocks,
            bookmarkCount: 28,
            favouriteCount: 5
        )
        ]
    }
}

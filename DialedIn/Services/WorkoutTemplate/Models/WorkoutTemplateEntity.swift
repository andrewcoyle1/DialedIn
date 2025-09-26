//
//  WorkoutTemplateEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import SwiftData

@Model
class WorkoutTemplateEntity {
    @Attribute(.unique) var workoutTemplateId: String
    var authorId: String?
    var name: String
    var workoutDescription: String?
    var imageURL: String?
    var dateCreated: Date
    var dateModified: Date
    var exercises: [String]
    var clickCount: Int?
    var bookmarkCount: Int?
    var favouriteCount: Int?
    
    init(from model: WorkoutTemplateModel) {
        self.workoutTemplateId = model.workoutId
        self.authorId = model.authorId
        self.name = model.name
        self.workoutDescription = model.description
        self.imageURL = model.imageURL
        self.dateCreated = model.dateCreated
        self.dateModified = model.dateModified
        self.exercises = model.exercises.map(\.exerciseId)
        self.clickCount = model.clickCount
        self.bookmarkCount = model.bookmarkCount
        self.favouriteCount = model.favouriteCount
    }
    
    @MainActor
    func toModel() -> WorkoutTemplateModel {
        WorkoutTemplateModel(
            id: workoutTemplateId,
            authorId: authorId ?? "",
            name: name,
            description: workoutDescription,
            imageURL: imageURL,
            dateCreated: dateCreated,
            dateModified: dateModified,
            exercises: [],
            clickCount: clickCount,
            bookmarkCount: bookmarkCount,
            favouriteCount: favouriteCount
        )
    }
}

//
//  ExerciseTemplateEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import SwiftData

@Model
class ExerciseTemplateEntity {
    @Attribute(.unique) var exerciseTemplateId: String
    var authorId: String?
    var name: String
    var exerciseDescription: String?
    var instructions: [String]
    var type: ExerciseCategory
    var muscleGroups: [MuscleGroup]
    var imageURL: String?
    var dateCreated: Date
    var dateModified: Date
    var clickCount: Int?
    var bookmarkCount: Int?
    var favouriteCount: Int?
    
    init(from model: ExerciseTemplateModel) {
        self.exerciseTemplateId = model.exerciseId
        self.authorId = model.authorId
        self.name = model.name
        self.exerciseDescription = model.description
        self.instructions = model.instructions
        self.type = model.type
        self.muscleGroups = model.muscleGroups
        self.imageURL = model.imageURL
        self.dateCreated = model.dateCreated
        self.dateModified = model.dateModified
        self.clickCount = model.clickCount
        self.bookmarkCount = model.bookmarkCount
        self.favouriteCount = model.favouriteCount
    }
    
    @MainActor
    func toModel() -> ExerciseTemplateModel {
        ExerciseTemplateModel(
            exerciseId: exerciseTemplateId,
            authorId: authorId,
            name: name,
            description: exerciseDescription,
            instructions: instructions,
            type: type,
            muscleGroups: muscleGroups,
            imageURL: imageURL,
            dateCreated: dateCreated,
            dateModified: dateModified,
            clickCount: clickCount,
            bookmarkCount: bookmarkCount,
            favouriteCount: favouriteCount
        )
    }
}

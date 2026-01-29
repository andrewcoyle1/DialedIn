//
//  ExerciseHistoryEntryEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI
import SwiftData

@Model
class ExerciseHistoryEntryEntity {
    @Attribute(.unique) var exerciseHistoryEntryId: String
    var authorId: String
    var templateId: String
    var templateName: String
    var workoutSessionId: String
    var workoutExerciseId: String
    var performedAt: Date
    var notes: String?
    @Relationship(deleteRule: .cascade, inverse: \ExerciseHistorySetEntity.entry) var sets: [ExerciseHistorySetEntity]
    var dateCreated: Date
    var dateModified: Date
    
    init(from model: ExerciseHistoryEntryModel) {
        self.exerciseHistoryEntryId = model.id
        self.authorId = model.authorId
        self.templateId = model.templateId
        self.templateName = model.templateName
        self.workoutSessionId = model.workoutSessionId
        self.workoutExerciseId = model.workoutExerciseId
        self.performedAt = model.performedAt
        self.notes = model.notes
        self.sets = model.sets.map { ExerciseHistorySetEntity(from: $0) }
        self.dateCreated = model.dateCreated
        self.dateModified = model.dateModified
    }
    
    @MainActor
    func toModel() -> ExerciseHistoryEntryModel {
        ExerciseHistoryEntryModel(
            id: exerciseHistoryEntryId,
            authorId: authorId,
            templateId: templateId,
            templateName: templateName,
            workoutSessionId: workoutSessionId,
            workoutExerciseId: workoutExerciseId,
            performedAt: performedAt,
            notes: notes,
            sets: sets.map { $0.toModel() },
            dateCreated: dateCreated,
            dateModified: dateModified
        )
    }
}

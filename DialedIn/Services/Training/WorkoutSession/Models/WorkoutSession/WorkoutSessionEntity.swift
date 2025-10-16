//
//  WorkoutTemplateEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import SwiftData

@Model
class WorkoutSessionEntity {
    @Attribute(.unique) var workoutSessionId: String
    var authorId: String
    var name: String
    var dateCreated: Date
    var endedAt: Date?
    var notes: String?
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExerciseEntity.session) var exercises: [WorkoutExerciseEntity]

    init(from model: WorkoutSessionModel) {
        self.workoutSessionId = model.id
        self.authorId = model.authorId
        self.name = model.name
        self.dateCreated = model.dateCreated
        self.endedAt = model.endedAt
        self.notes = model.notes
        // Persist exercises in index order
        self.exercises = model.exercises
            .sorted { ($0.index) < ($1.index) }
            .map { WorkoutExerciseEntity(from: $0) }
    }

    @MainActor
    func toModel() -> WorkoutSessionModel {
        WorkoutSessionModel(
            id: workoutSessionId,
            authorId: authorId,
            name: name,
            dateCreated: dateCreated,
            endedAt: endedAt,
            notes: notes,
            // Load exercises sorted by their own index; sets also sorted by index
            exercises: exercises
                .sorted { $0.index < $1.index }
                .map { entity in
                    var model = entity.toModel()
                    // Ensure sets are in index order
                    model.sets = model.sets.sorted(by: { $0.index < $1.index })
                    return model
                }
        )
    }
}

// Helper entity for exercises in a session
@Model
class WorkoutExerciseEntity {
    var id: String
    var authorId: String
    var templateId: String
    var name: String
    var trackingMode: TrackingMode
    var index: Int
    var notes: String?
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSetEntity.exercise) var sets: [WorkoutSetEntity]
    @Relationship var session: WorkoutSessionEntity?

    init(from model: WorkoutExerciseModel) {
        self.id = model.id
        self.authorId = model.authorId
        self.templateId = model.templateId
        self.name = model.name
        self.trackingMode = model.trackingMode
        self.index = model.index
        self.notes = model.notes
        // Persist sets in index order
        self.sets = model.sets.sorted(by: { $0.index < $1.index }).map { WorkoutSetEntity(from: $0) }
    }

    @MainActor
    func toModel() -> WorkoutExerciseModel {
        WorkoutExerciseModel(
            id: id,
            authorId: authorId,
            templateId: templateId,
            name: name,
            trackingMode: trackingMode,
            index: index,
            notes: notes,
            sets: sets.map { $0.toModel() }
        )
    }
}

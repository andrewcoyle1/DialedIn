//
//  ExerciseHistoryEntryModel.swift
//  DialedIn
//
//  Created by AI Assistant on 27/09/2025.
//

import Foundation
import IdentifiableByString

struct ExerciseHistoryEntryModel: Identifiable, Codable, StringIdentifiable, Hashable {
    let id: String
    let authorId: String
    let templateId: String
    let templateName: String
    let workoutSessionId: String
    let workoutExerciseId: String
    let performedAt: Date
    var notes: String?
    var sets: [WorkoutSetModel]
    let dateCreated: Date
    let dateModified: Date
    
    init(
        id: String,
        authorId: String,
        templateId: String,
        templateName: String,
        workoutSessionId: String,
        workoutExerciseId: String,
        performedAt: Date,
        notes: String? = nil,
        sets: [WorkoutSetModel],
        dateCreated: Date,
        dateModified: Date
    ) {
        self.id = id
        self.authorId = authorId
        self.templateId = templateId
        self.templateName = templateName
        self.workoutSessionId = workoutSessionId
        self.workoutExerciseId = workoutExerciseId
        self.performedAt = performedAt
        self.notes = notes
        self.sets = sets
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case templateId = "template_id"
        case templateName = "template_name"
        case workoutSessionId = "workout_session_id"
        case workoutExerciseId = "workout_exercise_id"
        case performedAt = "performed_at"
        case notes
        case sets
        case dateCreated = "date_created"
        case dateModified = "date_modified"
    }
    
    static func newEntry(
        authorId: String,
        templateId: String,
        templateName: String,
        workoutSessionId: String,
        workoutExerciseId: String,
        performedAt: Date = .now,
        notes: String? = nil,
        sets: [WorkoutSetModel]
    ) -> Self {
        ExerciseHistoryEntryModel(
            id: UUID().uuidString,
            authorId: authorId,
            templateId: templateId,
            templateName: templateName,
            workoutSessionId: workoutSessionId,
            workoutExerciseId: workoutExerciseId,
            performedAt: performedAt,
            notes: notes,
            sets: sets,
            dateCreated: .now,
            dateModified: .now
        )
    }
    
    static var mock: ExerciseHistoryEntryModel {
        mocks[0]
    }
    
    static var mocks: [ExerciseHistoryEntryModel] {
        let sampleSets = Array(WorkoutSetModel.mocks.prefix(3))
        return [
            ExerciseHistoryEntryModel(
                id: "eh_1",
                authorId: "1",
                templateId: "1",
                templateName: "Bench Press",
                workoutSessionId: "ws_1",
                workoutExerciseId: "we_1",
                performedAt: Date().addingTimeInterval(-3600),
                notes: "Felt strong",
                sets: sampleSets,
                dateCreated: Date().addingTimeInterval(-3600),
                dateModified: Date().addingTimeInterval(-3500)
            ),
            ExerciseHistoryEntryModel(
                id: "eh_2",
                authorId: "1",
                templateId: "2",
                templateName: "Squat",
                workoutSessionId: "ws_2",
                workoutExerciseId: "we_2",
                performedAt: Date().addingTimeInterval(-7200),
                notes: nil,
                sets: sampleSets,
                dateCreated: Date().addingTimeInterval(-7200),
                dateModified: Date().addingTimeInterval(-7100)
            )
        ]
    }
}

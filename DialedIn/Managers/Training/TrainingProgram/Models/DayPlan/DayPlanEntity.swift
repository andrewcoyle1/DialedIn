//
//  DayPlanEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import SwiftUI
import SwiftData

@Model
class DayPlanEntity {
    
    @Attribute(.unique) var id: String
    var authorId: String
    var name: String
    var dateCreated: Date
    
    @Relationship var trainingProgram: TrainingProgramEntity?
    @Relationship(deleteRule: .cascade, inverse: \ExercisePlanEntity.dayPlan) var exercises: [ExercisePlanEntity]

    @MainActor
    init(from model: DayPlan) {
        self.id = model.id
        self.authorId = model.authorId
        self.name = model.name
        self.dateCreated = model.dateCreated
        
        self.exercises = model.exercises
            .enumerated()
            .map { ExercisePlanEntity(from: $1, index: $0) }
    }

    @MainActor
    func toModel() -> DayPlan {
        let exercisePlans = exercises
            .sorted { $0.index < $1.index }
            .map { $0.toModel() }
        return DayPlan(
            id: id,
            authorId: authorId,
            name: name,
            dateCreated: dateCreated,
            exercises: exercisePlans
        )
    }
}

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
            .map { ExercisePlanEntity(from: $0) }
    }
    
    @MainActor
    func toModel() -> DayPlan {
        var exercisePlans: [WorkoutTemplateExercise] = []
        for exercise in exercises {
            exercisePlans.append(exercise.toModel())
        }
        return DayPlan(
            id: id,
            authorId: authorId,
            name: name,
            dateCreated: dateCreated,
            exercises: exercisePlans
        )
    }
}

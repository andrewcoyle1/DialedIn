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
    
    @Relationship var trainingProgram: TrainingProgramEntity?
    @Relationship(deleteRule: .cascade, inverse: \ExercisePlanEntity.dayPlan) var exercises: [ExercisePlanEntity]

    init(from model: DayPlan) {
        self.id = model.id
        self.authorId = model.authorId
        self.name = model.name
        
        self.exercises = model.exercises
            .map { ExercisePlanEntity(from: $0) }
    }
    
    @MainActor
    func toModel() -> DayPlan {
        var exercisePlans: [ExercisePlan] = [ ]
        for exercise in exercises {
            exercisePlans.append(exercise.toModel())
        }
        return DayPlan(
            id: id,
            authorId: authorId,
            name: name,
            exercises: exercisePlans
        )
    }
}

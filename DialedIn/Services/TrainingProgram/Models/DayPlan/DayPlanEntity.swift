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
    
    @Relationship(deleteRule: .cascade, inverse: \ExercisePlanEntity.dayPlan) var exercises: [ExercisePlanEntity]
    
    init(from model: DayPlan) {
        self.id = model.id
        self.authorId = model.authorId
        self.name = model.name
        
        var exerciseEntities: [ExercisePlanEntity] = []
        for exercise in model.exercises {
            exerciseEntities.append(ExercisePlanEntity(from: exercise))
        }
        self.exercises = exerciseEntities
        for exerciseEntity in exercises {
            exerciseEntity.dayPlan = self
        }
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

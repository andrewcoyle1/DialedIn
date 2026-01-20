//
//  ExercisePlanEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import SwiftUI
import SwiftData

@Model
class ExercisePlanEntity {
    
    @Attribute(.unique) var id: String
    var authorId: String
    var exercise: ExerciseTemplateEntity
    
    var dayPlan: DayPlanEntity?
    
    init(from model: ExercisePlan) {
        self.id = model.id
        self.authorId = model.authorId
        self.exercise = ExerciseTemplateEntity(from: model.exercise)
        self.dayPlan = nil
    }
    
    @MainActor
    func toModel() -> ExercisePlan {
        ExercisePlan(
            id: id,
            authorId: authorId,
            exercise: exercise.toModel()
        )
    }
}

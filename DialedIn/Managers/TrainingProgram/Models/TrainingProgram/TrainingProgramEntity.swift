//
//  TrainingProgramEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import SwiftUI
import SwiftData

@Model
class TrainingProgramEntity {
    
    @Attribute(.unique) var id: String
    var authorId: String
    var name: String
    var icon: String
    var colour: String
    var numMicrocycles: Int
    var deload: DeloadType
    var periodisation: Bool
    @Relationship(deleteRule: .cascade, inverse: \DayPlanEntity.trainingProgram) var dayPlans: [DayPlanEntity]
    var dateCreated: Date
    var dateModified: Date
    
    init(from model: TrainingProgram) {
        self.id = model.id
        self.authorId = model.authorId
        self.name = model.name
        self.icon = model.icon
        self.colour = model.colour
        self.numMicrocycles = model.numMicrocycles
        self.deload = model.deload
        self.periodisation = model.periodisation
        self.dateCreated = model.dateCreated
        self.dateModified = model.dateModified
        self.dayPlans = model.dayPlans
            .map { DayPlanEntity(from: $0) }

    }
    
    @MainActor
    func toModel() -> TrainingProgram {
        var dayPlanModels: [DayPlan] = []
        for dayPlan in dayPlans {
            var exercisePlanModels: [ExercisePlan] = []
            
            for exercisePlan in dayPlan.exercises {
                exercisePlanModels.append(ExercisePlan(id: exercisePlan.id, authorId: exercisePlan.authorId, exercise: exercisePlan.exercise.toModel()))
            }
            
            dayPlanModels.append(
                DayPlan(
                    id: dayPlan.id,
                    authorId: dayPlan.authorId,
                    name: dayPlan.name,
                    exercises: exercisePlanModels
                )
            )
        }
        
        return TrainingProgram(
            id: id,
            authorId: authorId,
            name: name,
            icon: icon,
            colour: colour,
            numMicrocycles: numMicrocycles,
            deload: deload,
            periodisation: periodisation,
            dayPlans: dayPlanModels,
            dateCreated: dateCreated,
            dateModified: dateModified
        )
    }
}

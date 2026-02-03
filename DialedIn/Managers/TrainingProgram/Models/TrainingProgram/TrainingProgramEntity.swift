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
    
    @MainActor
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
        let sortedDayPlans = dayPlans.sorted { $0.dateCreated < $1.dateCreated }
        for dayPlan in sortedDayPlans {
            let exercisePlanModels = dayPlan.exercises.map { $0.toModel() }
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

//
//  TrainingPlanEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/10/2025.
//

import SwiftUI
import SwiftData

@Model
class TrainingPlanEntity {
    @Attribute(.unique) var planId: String
    var userId: String?
    var name: String
    var planDescription: String?
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var programTemplateId: String?
    var createdAt: Date
    var modifiedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \TrainingWeekEntity.plan) var weeks: [TrainingWeekEntity]
    @Relationship(deleteRule: .cascade, inverse: \TrainingGoalEntity.plan) var goals: [TrainingGoalEntity]
    
    init(from model: TrainingPlan) {
        self.planId = model.planId
        self.userId = model.userId
        self.name = model.name
        self.planDescription = model.description
        self.startDate = model.startDate
        self.endDate = model.endDate
        self.isActive = model.isActive
        self.programTemplateId = model.programTemplateId
        self.createdAt = model.createdAt
        self.modifiedAt = model.modifiedAt
        self.weeks = model.weeks
            .sorted { $0.weekNumber < $1.weekNumber }
            .map { TrainingWeekEntity(from: $0) }
        self.goals = model.goals.map { TrainingGoalEntity(from: $0) }
    }
    
    @MainActor
    func toModel() -> TrainingPlan {
        TrainingPlan(
            planId: planId,
            userId: userId,
            name: name,
            description: planDescription,
            startDate: startDate,
            endDate: endDate,
            isActive: isActive,
            programTemplateId: programTemplateId,
            weeks: weeks
                .sorted { $0.weekNumber < $1.weekNumber }
                .map { $0.toModel() },
            goals: goals.map { $0.toModel() },
            createdAt: createdAt,
            modifiedAt: modifiedAt
        )
    }
}

@Model
class TrainingWeekEntity {
    var weekNumber: Int
    var notes: String?
    
    @Relationship(deleteRule: .cascade, inverse: \ScheduledWorkoutEntity.week) var scheduledWorkouts: [ScheduledWorkoutEntity]
    @Relationship var plan: TrainingPlanEntity?
    
    init(from model: TrainingWeek) {
        self.weekNumber = model.weekNumber
        self.notes = model.notes
        self.scheduledWorkouts = model.scheduledWorkouts.map { ScheduledWorkoutEntity(from: $0) }
    }
    
    @MainActor
    func toModel() -> TrainingWeek {
        TrainingWeek(
            weekNumber: weekNumber,
            scheduledWorkouts: scheduledWorkouts.map { $0.toModel() },
            notes: notes
        )
    }
}

@Model
class ScheduledWorkoutEntity {
    @Attribute(.unique) var id: String
    var workoutTemplateId: String
    var dayOfWeek: Int
    var scheduledDate: Date?
    var completedSessionId: String?
    var isCompleted: Bool
    var notes: String?
    
    @Relationship var week: TrainingWeekEntity?
    
    init(from model: ScheduledWorkout) {
        self.id = model.id
        self.workoutTemplateId = model.workoutTemplateId
        self.dayOfWeek = model.dayOfWeek
        self.scheduledDate = model.scheduledDate
        self.completedSessionId = model.completedSessionId
        self.isCompleted = model.isCompleted
        self.notes = model.notes
    }
    
    @MainActor
    func toModel() -> ScheduledWorkout {
        ScheduledWorkout(
            id: id,
            workoutTemplateId: workoutTemplateId,
            dayOfWeek: dayOfWeek,
            scheduledDate: scheduledDate,
            completedSessionId: completedSessionId,
            isCompleted: isCompleted,
            notes: notes
        )
    }
}

@Model
class TrainingGoalEntity {
    @Attribute(.unique) var id: String
    var type: GoalType
    var targetValue: Double
    var currentValue: Double
    var targetDate: Date?
    var exerciseId: String?
    
    @Relationship var plan: TrainingPlanEntity?
    
    init(from model: TrainingGoal) {
        self.id = model.id
        self.type = model.type
        self.targetValue = model.targetValue
        self.currentValue = model.currentValue
        self.targetDate = model.targetDate
        self.exerciseId = model.exerciseId
    }
    
    @MainActor
    func toModel() -> TrainingGoal {
        TrainingGoal(
            id: id,
            type: type,
            targetValue: targetValue,
            currentValue: currentValue,
            targetDate: targetDate,
            exerciseId: exerciseId
        )
    }
}

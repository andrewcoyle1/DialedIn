//
//  TrainingPlanManager+WorkoutManagement.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import Foundation

extension TrainingPlanManager {
    
    // MARK: - Workout Scheduling
    
    func scheduleWorkout(
        workoutTemplateId: String,
        workoutName: String? = nil,
        on date: Date,
        weekNumber: Int? = nil
    ) async throws {
        guard var plan = currentTrainingPlan else {
            throw TrainingPlanError.noActivePlan
        }
        
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        // Determine week number if not provided
        let targetWeekNumber: Int
        if let weekNum = weekNumber {
            targetWeekNumber = weekNum
        } else {
            let weeksSinceStart = calendar.dateComponents([.weekOfYear], from: plan.startDate, to: date).weekOfYear ?? 0
            targetWeekNumber = weeksSinceStart + 1
        }
        
        let scheduledWorkout = ScheduledWorkout(
            workoutTemplateId: workoutTemplateId,
            workoutName: workoutName,
            dayOfWeek: dayOfWeek,
            scheduledDate: date
        )
        
        // Find or create week
        if let weekIndex = plan.weeks.firstIndex(where: { $0.weekNumber == targetWeekNumber }) {
            plan.weeks[weekIndex].scheduledWorkouts.append(scheduledWorkout)
        } else {
            let newWeek = TrainingWeek(weekNumber: targetWeekNumber, scheduledWorkouts: [scheduledWorkout])
            plan.addWeek(newWeek)
        }
        
        try await updatePlan(plan)
    }
    
    func rescheduleWorkout(
        scheduledWorkoutId: String,
        to newDate: Date
    ) async throws {
        guard var plan = currentTrainingPlan else {
            throw TrainingPlanError.noActivePlan
        }
        
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: newDate)
        
        // Find and update the workout
        for (weekIndex, week) in plan.weeks.enumerated() {
            if let workoutIndex = week.scheduledWorkouts.firstIndex(where: { $0.id == scheduledWorkoutId }) {
                var updatedWorkout = week.scheduledWorkouts[workoutIndex]
                updatedWorkout = ScheduledWorkout(
                    id: updatedWorkout.id,
                    workoutTemplateId: updatedWorkout.workoutTemplateId,
                    workoutName: updatedWorkout.workoutName,
                    dayOfWeek: dayOfWeek,
                    scheduledDate: newDate,
                    completedSessionId: updatedWorkout.completedSessionId,
                    isCompleted: updatedWorkout.isCompleted,
                    notes: updatedWorkout.notes
                )
                plan.weeks[weekIndex].scheduledWorkouts[workoutIndex] = updatedWorkout
                try await updatePlan(plan)
                return
            }
        }
        
        throw TrainingPlanError.workoutNotFound
    }
    
    func removeScheduledWorkout(id: String) async throws {
        guard var plan = currentTrainingPlan else {
            throw TrainingPlanError.noActivePlan
        }
        
        for (weekIndex, week) in plan.weeks.enumerated() {
            if let workoutIndex = week.scheduledWorkouts.firstIndex(where: { $0.id == id }) {
                plan.weeks[weekIndex].scheduledWorkouts.remove(at: workoutIndex)
                try await updatePlan(plan)
                return
            }
        }
        
        throw TrainingPlanError.workoutNotFound
    }
    
    // MARK: - Workout Completion
    
    func completeWorkout(
        scheduledWorkoutId: String,
        session: WorkoutSessionModel
    ) async throws {
        guard var plan = currentTrainingPlan else {
            throw TrainingPlanError.noActivePlan
        }
        
        // Find and mark workout as completed
        for (weekIndex, week) in plan.weeks.enumerated() {
            if let workoutIndex = week.scheduledWorkouts.firstIndex(where: { $0.id == scheduledWorkoutId }) {
                var updatedWorkout = week.scheduledWorkouts[workoutIndex]
                updatedWorkout = ScheduledWorkout(
                    id: updatedWorkout.id,
                    workoutTemplateId: updatedWorkout.workoutTemplateId,
                    workoutName: updatedWorkout.workoutName,
                    dayOfWeek: updatedWorkout.dayOfWeek,
                    scheduledDate: updatedWorkout.scheduledDate,
                    completedSessionId: session.id,
                    isCompleted: true,
                    notes: updatedWorkout.notes
                )
                plan.weeks[weekIndex].scheduledWorkouts[workoutIndex] = updatedWorkout
                try await updatePlan(plan)
                return
            }
        }
        
        throw TrainingPlanError.workoutNotFound
    }
    
    func markWorkoutIncomplete(scheduledWorkoutId: String) async throws {
        guard var plan = currentTrainingPlan else {
            throw TrainingPlanError.noActivePlan
        }
        
        for (weekIndex, week) in plan.weeks.enumerated() {
            if let workoutIndex = week.scheduledWorkouts.firstIndex(where: { $0.id == scheduledWorkoutId }) {
                var updatedWorkout = week.scheduledWorkouts[workoutIndex]
                updatedWorkout = ScheduledWorkout(
                    id: updatedWorkout.id,
                    workoutTemplateId: updatedWorkout.workoutTemplateId,
                    workoutName: updatedWorkout.workoutName,
                    dayOfWeek: updatedWorkout.dayOfWeek,
                    scheduledDate: updatedWorkout.scheduledDate,
                    completedSessionId: nil,
                    isCompleted: false,
                    notes: updatedWorkout.notes
                )
                plan.weeks[weekIndex].scheduledWorkouts[workoutIndex] = updatedWorkout
                try await updatePlan(plan)
                return
            }
        }
        
        throw TrainingPlanError.workoutNotFound
    }
    
    /// Syncs scheduled workout completion status with completed workout sessions
    /// This is useful for reconciling state after retroactive fixes or data migrations
    func syncScheduledWorkoutsWithCompletedSessions(completedSessions: [WorkoutSessionModel]) async throws {
        guard var plan = currentTrainingPlan else {
            throw TrainingPlanError.noActivePlan
        }
        
        var planWasModified = false
        
        // Build a map of scheduledWorkoutId -> completed session for quick lookup
        let completedSessionsMap = Dictionary(
            completedSessions
                .filter { $0.endedAt != nil && $0.scheduledWorkoutId != nil }
                .map { ($0.scheduledWorkoutId!, $0) },
            uniquingKeysWith: { first, _ in first } // Keep first if duplicates
        )
        
        // Check each scheduled workout
        for (weekIndex, week) in plan.weeks.enumerated() {
            for (workoutIndex, scheduledWorkout) in week.scheduledWorkouts.enumerated() {
                // If scheduled workout is marked incomplete but we have a completed session for it
                if !scheduledWorkout.isCompleted,
                   let completedSession = completedSessionsMap[scheduledWorkout.id] {
                    
                    // Update the scheduled workout
                    let updatedWorkout = ScheduledWorkout(
                        id: scheduledWorkout.id,
                        workoutTemplateId: scheduledWorkout.workoutTemplateId,
                        workoutName: scheduledWorkout.workoutName,
                        dayOfWeek: scheduledWorkout.dayOfWeek,
                        scheduledDate: scheduledWorkout.scheduledDate,
                        completedSessionId: completedSession.id,
                        isCompleted: true,
                        notes: scheduledWorkout.notes
                    )
                    
                    plan.weeks[weekIndex].scheduledWorkouts[workoutIndex] = updatedWorkout
                    planWasModified = true
                }
            }
        }
        
        // Save plan if any changes were made
        if planWasModified {
            try await updatePlan(plan)
        }
    }
}

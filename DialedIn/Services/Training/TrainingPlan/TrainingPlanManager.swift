//
//  TrainingPlanManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import Foundation

@Observable
class TrainingPlanManager {
    
    private let local: LocalTrainingPlanPersistence
    private let remote: RemoteTrainingPlanService
    private(set) var currentTrainingPlan: TrainingPlan?
    private(set) var allPlans: [TrainingPlan] = []
    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    
    init(services: TrainingPlanServices) {
        self.remote = services.remote
        self.local = services.local
        self.currentTrainingPlan = local.getCurrentTrainingPlan()
        self.allPlans = local.getAllPlans()
    }
    
    // MARK: - Plan Management
    
    func createPlan(_ plan: TrainingPlan) async throws {
        try local.savePlan(plan)
        allPlans = local.getAllPlans()
        
        // If this is the first plan or marked as active, set as current
        if plan.isActive {
            setActivePlan(plan)
        }
        
        // Sync to remote
        Task {
            try? await remote.createPlan(plan)
        }
    }
    
    func createPlanFromTemplate(
        _ template: ProgramTemplateModel,
        startDate: Date,
        userId: String,
        planName: String? = nil
    ) async throws -> TrainingPlan {
        // Use ProgramTemplateManager to instantiate
        let plan = instantiatePlanFromTemplate(template, userId: userId, startDate: startDate, planName: planName)
        try await createPlan(plan)
        return plan
    }
    
    func createBlankPlan(
        name: String,
        userId: String,
        description: String? = nil,
        startDate: Date = .now
    ) async throws -> TrainingPlan {
        let plan = TrainingPlan.newPlan(name: name, userId: userId, description: description, startDate: startDate)
        try await createPlan(plan)
        return plan
    }
    
    func updatePlan(_ plan: TrainingPlan) async throws {
        try local.savePlan(plan)
        
        if currentTrainingPlan?.planId == plan.planId {
            currentTrainingPlan = plan
        }
        
        allPlans = local.getAllPlans()
        
        // Sync to remote
        Task {
            try? await remote.updatePlan(plan)
        }
    }
    
    func deletePlan(id: String) async throws {
        try local.deletePlan(id: id)
        
        if currentTrainingPlan?.planId == id {
            currentTrainingPlan = nil
        }
        
        allPlans = local.getAllPlans()
        
        // Sync to remote
        Task {
            try? await remote.deletePlan(id: id)
        }
    }
    
    func setActivePlan(_ plan: TrainingPlan) {
        // Deactivate current plan
        if let current = currentTrainingPlan, current.planId != plan.planId {
            var updatedCurrent = current
            updatedCurrent = TrainingPlan(
                planId: updatedCurrent.planId,
                userId: updatedCurrent.userId,
                name: updatedCurrent.name,
                description: updatedCurrent.description,
                startDate: updatedCurrent.startDate,
                endDate: updatedCurrent.endDate,
                isActive: false,
                programTemplateId: updatedCurrent.programTemplateId,
                weeks: updatedCurrent.weeks,
                goals: updatedCurrent.goals,
                createdAt: updatedCurrent.createdAt,
                modifiedAt: .now
            )
            try? local.savePlan(updatedCurrent)
        }
        
        // Activate new plan
        var activePlan = plan
        if !activePlan.isActive {
            activePlan = TrainingPlan(
                planId: activePlan.planId,
                userId: activePlan.userId,
                name: activePlan.name,
                description: activePlan.description,
                startDate: activePlan.startDate,
                endDate: activePlan.endDate,
                isActive: true,
                programTemplateId: activePlan.programTemplateId,
                weeks: activePlan.weeks,
                goals: activePlan.goals,
                createdAt: activePlan.createdAt,
                modifiedAt: .now
            )
        }
        
        try? local.savePlan(activePlan)
        currentTrainingPlan = activePlan
        allPlans = local.getAllPlans()
    }
    
    // MARK: - Workout Scheduling
    
    func scheduleWorkout(
        workoutTemplateId: String,
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
    
    // MARK: - Progress Tracking
    
    func getWeeklyProgress(for weekNumber: Int) -> WeekProgress {
        guard let plan = currentTrainingPlan else {
            return WeekProgress(weekNumber: weekNumber, totalWorkouts: 0, completedWorkouts: 0, scheduledWorkouts: [])
        }
        return plan.weekProgress(for: weekNumber)
    }
    
    func getCurrentWeek() -> TrainingWeek? {
        currentTrainingPlan?.currentWeek()
    }
    
    func getUpcomingWorkouts(limit: Int = 5) -> [ScheduledWorkout] {
        guard let plan = currentTrainingPlan else { return [] }
        
        let allWorkouts = plan.weeks.flatMap { $0.scheduledWorkouts }
        return allWorkouts
            .filter { !$0.isCompleted && ($0.scheduledDate ?? Date.distantFuture) >= Date() }
            .sorted { ($0.scheduledDate ?? Date.distantFuture) < ($1.scheduledDate ?? Date.distantFuture) }
            .prefix(limit)
            .map { $0 }
    }
    
    func getTodaysWorkouts() -> [ScheduledWorkout] {
        guard let plan = currentTrainingPlan else { return [] }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return plan.weeks.flatMap { $0.scheduledWorkouts }
            .filter { workout in
                guard let date = workout.scheduledDate else { return false }
                return calendar.isDate(date, inSameDayAs: today)
            }
    }
    
    func getAdherenceRate() -> Double {
        currentTrainingPlan?.adherenceRate ?? 0
    }
    
    // MARK: - Goal Management
    
    func addGoal(_ goal: TrainingGoal) async throws {
        guard var plan = currentTrainingPlan else {
            throw TrainingPlanError.noActivePlan
        }
        
        plan.goals.append(goal)
        try await updatePlan(plan)
    }
    
    func updateGoal(_ goal: TrainingGoal) async throws {
        guard var plan = currentTrainingPlan else {
            throw TrainingPlanError.noActivePlan
        }
        
        plan.updateGoal(goal)
        try await updatePlan(plan)
    }
    
    func removeGoal(id: String) async throws {
        guard var plan = currentTrainingPlan else {
            throw TrainingPlanError.noActivePlan
        }
        
        plan.goals.removeAll { $0.id == id }
        try await updatePlan(plan)
    }
    
    // MARK: - Smart Suggestions
    
    func suggestNextWeekWorkouts(basedOn currentWeek: TrainingWeek) -> [ScheduledWorkout] {
        // Simple implementation: repeat the same workout schedule
        // Can be enhanced with progressive overload logic
        let calendar = Calendar.current
        
        return currentWeek.scheduledWorkouts.map { workout in
            let nextWeekDate = calendar.date(byAdding: .weekOfYear, value: 1, to: workout.scheduledDate ?? Date())
            
            return ScheduledWorkout(
                workoutTemplateId: workout.workoutTemplateId,
                dayOfWeek: workout.dayOfWeek,
                scheduledDate: nextWeekDate
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func instantiatePlanFromTemplate(
        _ template: ProgramTemplateModel,
        userId: String,
        startDate: Date,
        planName: String?
    ) -> TrainingPlan {
        let weeks = template.weekTemplates.map { weekTemplate in
            let scheduledWorkouts = weekTemplate.workoutSchedule.map { mapping in
                let weekOffset = weekTemplate.weekNumber - 1
                let scheduledDate = calculateDate(
                    startDate: startDate,
                    weekOffset: weekOffset,
                    dayOfWeek: mapping.dayOfWeek
                )
                
                return ScheduledWorkout(
                    workoutTemplateId: mapping.workoutTemplateId,
                    dayOfWeek: mapping.dayOfWeek,
                    scheduledDate: scheduledDate
                )
            }
            
            return TrainingWeek(
                weekNumber: weekTemplate.weekNumber,
                scheduledWorkouts: scheduledWorkouts,
                notes: weekTemplate.notes
            )
        }
        
        let endDate = Calendar.current.date(
            byAdding: .weekOfYear,
            value: template.duration,
            to: startDate
        )
        
        return TrainingPlan(
            planId: UUID().uuidString,
            userId: userId,
            name: planName ?? template.name,
            description: template.description,
            startDate: startDate,
            endDate: endDate,
            isActive: true,
            programTemplateId: template.id,
            weeks: weeks,
            goals: [],
            createdAt: .now,
            modifiedAt: .now
        )
    }
    
    private func calculateDate(startDate: Date, weekOffset: Int, dayOfWeek: Int) -> Date {
        let calendar = Calendar.current
        
        // For week 1, find the first occurrence of this day of week on or after start date
        if weekOffset == 0 {
            return findNextDayOfWeek(dayOfWeek, onOrAfter: startDate)
        }
        
        // For subsequent weeks, calculate from the first week's anchor
        let week1Date = findNextDayOfWeek(dayOfWeek, onOrAfter: startDate)
        guard let targetDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: week1Date) else {
            return startDate
        }
        
        return targetDate
    }
    
    private func findNextDayOfWeek(_ targetDayOfWeek: Int, onOrAfter date: Date) -> Date {
        let calendar = Calendar.current
        let currentDayOfWeek = calendar.component(.weekday, from: date)
        
        // If today is the target day, return today
        if currentDayOfWeek == targetDayOfWeek {
            return date
        }
        
        // Calculate days to add
        var daysToAdd = targetDayOfWeek - currentDayOfWeek
        if daysToAdd < 0 {
            daysToAdd += 7 // Move to next week
        }
        
        guard let targetDate = calendar.date(byAdding: .day, value: daysToAdd, to: date) else {
            return date
        }
        
        return targetDate
    }
    
    // MARK: - Sync Operations
    
    func syncFromRemote() async throws {
        isLoading = true
        error = nil
        
        do {
            let remotePlans = try await remote.fetchAllPlans()
            
            // Save all remote plans locally
            for plan in remotePlans {
                try? local.savePlan(plan)
            }
            
            allPlans = local.getAllPlans()
            currentTrainingPlan = local.getCurrentTrainingPlan()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
}

enum TrainingPlanError: Error, LocalizedError {
    case noActivePlan
    case workoutNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .noActivePlan:
            return "No active training plan"
        case .workoutNotFound:
            return "Scheduled workout not found"
        case .invalidData:
            return "Invalid data"
        }
    }
}

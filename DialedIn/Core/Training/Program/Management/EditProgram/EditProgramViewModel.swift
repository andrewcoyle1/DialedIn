//
//  EditProgramViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class EditProgramViewModel {
    private let workoutTemplateManager: WorkoutTemplateManager
    private let trainingPlanManager: TrainingPlanManager
    private let programTemplateManager: ProgramTemplateManager
    
    var name: String = ""
    var description: String = ""
    var startDate: Date = .now
    var endDate: Date?
    var hasEndDate: Bool = false
    private(set) var isSaving = false
    var showDateChangeAlert = false
    var showDeleteActiveAlert = false
    var pendingStartDate: Date?
    
    var originalStartDate: Date = .now
    
    init(
        container: DependencyContainer
    ) {
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.programTemplateManager = container.resolve(ProgramTemplateManager.self)!
        
        // Initialize with default values - will be set by the view
        self.name = ""
        self.description = ""
        self.startDate = .now
        self.endDate = nil
        self.hasEndDate = false
        self.originalStartDate = .now
    }
    
    func totalWorkouts(for plan: TrainingPlan) -> Int {
        plan.weeks.flatMap { $0.scheduledWorkouts }.count
    }
    
    func completedWorkouts(for plan: TrainingPlan) -> Int {
        plan.weeks.flatMap { $0.scheduledWorkouts }.filter { $0.isCompleted }.count
    }
    
    func calculateWeeks(from startDate: Date, to endDate: Date) -> Int {
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: endDate).weekOfYear ?? 0
        return max(weeks, 0)
    }
    
    func deleteActivePlan(plan: TrainingPlan, onDismiss: @escaping @MainActor () -> Void) async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            try await trainingPlanManager.deletePlan(id: plan.planId)
            onDismiss()
        } catch {
            print("Error deleting active plan: \(error)")
        }
    }
    
    func savePlan(plan: TrainingPlan, onDismiss: @escaping @MainActor () -> Void) async {
        isSaving = true
        defer { isSaving = false }
        
        var updatedWeeks = plan.weeks
        if startDate != originalStartDate {
            updatedWeeks = rescheduleWorkouts(weeks: plan.weeks, oldStartDate: originalStartDate, newStartDate: startDate)
        }
        
        let adjustedEndDate = calculateAdjustedEndDate(originalEndDate: plan.endDate)
        updatedWeeks = await handleEndDateChanges(
            weeks: updatedWeeks,
            originalEndDate: plan.endDate,
            adjustedEndDate: adjustedEndDate,
            programTemplateId: plan.programTemplateId
        )
        
        let updatedPlan = createUpdatedPlan(from: plan, weeks: updatedWeeks, adjustedEndDate: adjustedEndDate)
        await sendUpdatedPlan(updatedPlan: updatedPlan, onDismiss: onDismiss)
    }
    
    private func calculateAdjustedEndDate(originalEndDate: Date?) -> Date? {
        return hasEndDate ? endDate : nil
    }
    
    private func handleEndDateChanges(
        weeks: [TrainingWeek],
        originalEndDate: Date?,
        adjustedEndDate: Date?,
        programTemplateId: String?
    ) async -> [TrainingWeek] {
        var updatedWeeks = weeks
        
        if adjustedEndDate != originalEndDate {
            if let newEnd = adjustedEndDate {
                if let oldEnd = originalEndDate, newEnd > oldEnd {
                    do {
                        updatedWeeks = try await extendProgramSchedule(
                            weeks: updatedWeeks,
                            startDate: startDate,
                            oldEndDate: oldEnd,
                            newEndDate: newEnd,
                            programTemplateId: programTemplateId
                        )
                    } catch {
                        print("Error extending program schedule: \(error)")
                    }
                } else {
                    updatedWeeks = filterWorkoutsByEndDate(weeks: updatedWeeks, endDate: newEnd)
                }
            }
        }
        
        return updatedWeeks
    }
    
    private func createUpdatedPlan(from plan: TrainingPlan, weeks: [TrainingWeek], adjustedEndDate: Date?) -> TrainingPlan {
        TrainingPlan(
            planId: plan.planId,
            userId: plan.userId,
            name: name,
            description: description.isEmpty ? nil : description,
            startDate: startDate,
            endDate: adjustedEndDate,
            isActive: plan.isActive,
            programTemplateId: plan.programTemplateId,
            weeks: weeks,
            goals: plan.goals,
            createdAt: plan.createdAt,
            modifiedAt: .now
        )
    }
    
    func sendUpdatedPlan(updatedPlan: TrainingPlan, onDismiss: @escaping @MainActor () -> Void) async {
        do {
            try await trainingPlanManager.updatePlan(updatedPlan)
            onDismiss()
        } catch {
            print("Error updating plan: \(error)")
        }
    }
    
    func rescheduleWorkouts(weeks: [TrainingWeek], oldStartDate: Date, newStartDate: Date) -> [TrainingWeek] {
        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: oldStartDate, to: newStartDate).day ?? 0
        
        return weeks.map { week in
            let updatedWorkouts = week.scheduledWorkouts.map { workout in
                var updatedWorkout = workout
                if let oldDate = workout.scheduledDate,
                   let newDate = calendar.date(byAdding: .day, value: daysDifference, to: oldDate) {
                    updatedWorkout = ScheduledWorkout(
                        id: workout.id,
                        workoutTemplateId: workout.workoutTemplateId,
                        workoutName: workout.workoutName,
                        dayOfWeek: calendar.component(.weekday, from: newDate),
                        scheduledDate: newDate,
                        completedSessionId: workout.completedSessionId,
                        isCompleted: workout.isCompleted,
                        notes: workout.notes
                    )
                }
                return updatedWorkout
            }
            
            return TrainingWeek(
                weekNumber: week.weekNumber,
                scheduledWorkouts: updatedWorkouts,
                notes: week.notes
            )
        }
    }
    
    func filterWorkoutsByEndDate(weeks: [TrainingWeek], endDate: Date) -> [TrainingWeek] {
        return weeks.map { week in
            let filteredWorkouts = week.scheduledWorkouts.filter { workout in
                // Keep completed workouts regardless of date
                if workout.isCompleted {
                    return true
                }
                // Filter future workouts by end date
                guard let scheduledDate = workout.scheduledDate else {
                    return true
                }
                return scheduledDate <= endDate
            }
            
            return TrainingWeek(
                weekNumber: week.weekNumber,
                scheduledWorkouts: filteredWorkouts,
                notes: week.notes
            )
        }.filter { !$0.scheduledWorkouts.isEmpty || $0.notes != nil }
    }
    
    func extendProgramSchedule(
        weeks: [TrainingWeek],
        startDate: Date,
        oldEndDate: Date,
        newEndDate: Date,
        programTemplateId: String?
    ) async throws -> [TrainingWeek] {
        // Debug: List all available templates
        let allTemplates = programTemplateManager.getAll()
        for template in allTemplates {
            print("  - \(template.id): \(template.name)")
        }
        
        // If no template, can't auto-extend
        guard let templateId = programTemplateId else {
            return weeks
        }
        
        // Try to get template locally first
        var template = programTemplateManager.get(id: templateId)
        
        // If not found locally, try to fetch from Firebase
        if template == nil {
            do {
                template = try await programTemplateManager.fetchTemplateFromRemote(id: templateId)
            } catch {
                return weeks
            }
        }
        
        guard let template = template else {
            return weeks
        }
                
        guard !template.weekTemplates.isEmpty else {
            return weeks
        }
        
        var updatedWeeks = weeks
        
        // Use date-based approach: iterate through each day in the extended range
        let calendar = Calendar.current
        let startOfOldEnd = calendar.startOfDay(for: oldEndDate)
        let startOfNewEnd = calendar.startOfDay(for: newEndDate)
        
        // Start from the day after the old end date
        guard var currentDate = calendar.date(byAdding: .day, value: 1, to: startOfOldEnd) else {
            return weeks
        }
        
        // Dictionary to group workouts by week number
        var workoutsByWeek: [Int: [ScheduledWorkout]] = [:]
        
        // Iterate through each day in the extended range
        while currentDate <= startOfNewEnd {
            let dayOfWeek = calendar.component(.weekday, from: currentDate)
            
            // Calculate which week this date belongs to
            let weeksSinceStart = calendar.dateComponents([.weekOfYear], from: startDate, to: currentDate).weekOfYear ?? 0
            let weekNumber = weeksSinceStart + 1
            
            // Find the corresponding template week (cycling through template)
            let templateIndex = (weekNumber - 1) % template.weekTemplates.count
            let weekTemplate = template.weekTemplates[templateIndex]
            
            // Check if this template week has a workout scheduled for this day of week
            if let mapping = weekTemplate.workoutSchedule.first(where: { $0.dayOfWeek == dayOfWeek }) {
                
                // Fetch workout name
                let workoutName: String? = mapping.workoutName ?? {
                    if let template = try? workoutTemplateManager.getLocalWorkoutTemplate(id: mapping.workoutTemplateId) {
                        return template.name
                    }
                    return nil
                }()
                
                let workout = ScheduledWorkout(
                    workoutTemplateId: mapping.workoutTemplateId,
                    workoutName: workoutName,
                    dayOfWeek: dayOfWeek,
                    scheduledDate: currentDate
                )
                
                // Group by week number
                if workoutsByWeek[weekNumber] == nil {
                    workoutsByWeek[weekNumber] = []
                }
                workoutsByWeek[weekNumber]?.append(workout)
            }
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Add the grouped workouts as training weeks
        for (weekNumber, workouts) in workoutsByWeek.sorted(by: { $0.key < $1.key }) {
            let templateIndex = (weekNumber - 1) % template.weekTemplates.count
            let weekTemplate = template.weekTemplates[templateIndex]
            
            // Check if this week already exists in updatedWeeks
            if let existingWeekIndex = updatedWeeks.firstIndex(where: { $0.weekNumber == weekNumber }) {
                // Append to existing week
                updatedWeeks[existingWeekIndex].scheduledWorkouts.append(contentsOf: workouts)
            } else {
                // Create new week
                let newWeek = TrainingWeek(
                    weekNumber: weekNumber,
                    scheduledWorkouts: workouts,
                    notes: weekTemplate.notes
                )
                updatedWeeks.append(newWeek)
            }
        }
        
        return updatedWeeks.sorted { $0.weekNumber < $1.weekNumber }
    }
    
    func calculateScheduleDate(startDate: Date, weekOffset: Int, dayOfWeek: Int) -> Date {
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
    
    func findNextDayOfWeek(_ targetDayOfWeek: Int, onOrAfter date: Date) -> Date {
        let calendar = Calendar.current
        let currentDayOfWeek = calendar.component(.weekday, from: date)
        
        if currentDayOfWeek == targetDayOfWeek {
            return date
        }
        
        var daysToAdd = targetDayOfWeek - currentDayOfWeek
        if daysToAdd < 0 {
            daysToAdd += 7
        }
        
        guard let targetDate = calendar.date(byAdding: .day, value: daysToAdd, to: date) else {
            return date
        }
        
        return targetDate
    }
}

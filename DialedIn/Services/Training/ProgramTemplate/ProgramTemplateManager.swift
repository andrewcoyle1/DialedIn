//
//  ProgramTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation

@Observable
class ProgramTemplateManager {
    
    private let local: LocalProgramTemplatePersistence
    private let remote: RemoteProgramTemplateService
    
    private(set) var templates: [ProgramTemplateModel] = []
    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    
    init(services: ProgramTemplateServices) {
        self.local = services.local
        self.remote = services.remote
        self.templates = local.getAll()
    }
    
    // MARK: - CRUD Operations
    
    func getAll() -> [ProgramTemplateModel] {
        local.getAll()
    }
    
    func get(id: String) -> ProgramTemplateModel? {
        local.get(id: id)
    }
    
    func getBuiltInTemplates() -> [ProgramTemplateModel] {
        local.getBuiltInTemplates()
    }
    
    func create(_ template: ProgramTemplateModel) async throws {
        try local.save(template)
        templates = local.getAll()
        
        // Sync to remote in background
        Task {
            try? await remote.create(template)
        }
    }
    
    func update(_ template: ProgramTemplateModel) async throws {
        try local.save(template)
        templates = local.getAll()
        
        // Sync to remote in background
        Task {
            try? await remote.update(template)
        }
    }
    
    func delete(id: String) async throws {
        try local.delete(id: id)
        templates = local.getAll()
        
        // Sync to remote in background
        Task {
            try? await remote.delete(id: id)
        }
    }
    
    // MARK: - Sync Operations
    
    func syncFromRemote() async throws {
        isLoading = true
        error = nil
        
        do {
            let remoteTemplates = try await remote.fetchAll()
            
            // Save all remote templates locally
            for template in remoteTemplates {
                try? local.save(template)
            }
            
            templates = local.getAll()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    func fetchPublicTemplates() async throws -> [ProgramTemplateModel] {
        try await remote.fetchPublicTemplates()
    }
    
    // MARK: - Template Instantiation
    
    /// Converts a ProgramTemplate into a TrainingPlan ready to be used
    func instantiateTemplate(
        _ template: ProgramTemplateModel,
        for userId: String,
        startDate: Date,
        endDate: Date? = nil,
        planName: String? = nil,
        workoutTemplateManager: WorkoutTemplateManager? = nil
    ) -> TrainingPlan {
        let weeks: [TrainingWeek] = template.weekTemplates.map { weekTemplate -> TrainingWeek in
            let scheduledWorkouts: [ScheduledWorkout] = weekTemplate.workoutSchedule.compactMap { mapping -> ScheduledWorkout? in
                let weekOffset = weekTemplate.weekNumber - 1
                let scheduledDate = calculateDate(
                    startDate: startDate,
                    weekOffset: weekOffset,
                    dayOfWeek: mapping.dayOfWeek
                )
                
                // Filter out workouts beyond end date
                if let endDate = endDate, scheduledDate > endDate {
                    return nil
                }
                
                let workoutName = resolveWorkoutName(
                    from: mapping,
                    using: workoutTemplateManager
                )
                
                return ScheduledWorkout(
                    workoutTemplateId: mapping.workoutTemplateId,
                    workoutName: workoutName,
                    dayOfWeek: mapping.dayOfWeek,
                    scheduledDate: scheduledDate
                )
            }
            
            return TrainingWeek(
                weekNumber: weekTemplate.weekNumber,
                scheduledWorkouts: scheduledWorkouts,
                notes: weekTemplate.notes
            )
        }.filter { (week: TrainingWeek) -> Bool in
            !week.scheduledWorkouts.isEmpty
        }
        
        let calculatedEndDate = endDate ?? Calendar.current.date(
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
            endDate: calculatedEndDate,
            isActive: true,
            programTemplateId: template.id,
            weeks: weeks,
            goals: [],
            createdAt: .now,
            modifiedAt: .now
        )
    }
    
    // MARK: - Helper Methods
    
    private func resolveWorkoutName(
        from mapping: DayWorkoutMapping,
        using workoutTemplateManager: WorkoutTemplateManager?
    ) -> String? {
        if let name = mapping.workoutName {
            return name
        }
        guard let manager = workoutTemplateManager,
              let template = try? manager.getLocalWorkoutTemplate(id: mapping.workoutTemplateId) else {
            return nil
        }
        return template.name
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
    
    func templatesByDifficulty(_ difficulty: DifficultyLevel) -> [ProgramTemplateModel] {
        templates.filter { $0.difficulty == difficulty }
    }
    
    func templatesByFocusArea(_ focusArea: FocusArea) -> [ProgramTemplateModel] {
        templates.filter { $0.focusAreas.contains(focusArea) }
    }
    
    // MARK: - Filtering Helpers
    
    func isBuiltIn(_ template: ProgramTemplateModel) -> Bool {
        ProgramTemplateModel.builtInTemplates.contains(where: { $0.id == template.id })
    }
    
    func getUserTemplates(userId: String) -> [ProgramTemplateModel] {
        getAll()
            .filter { $0.authorId == userId && !isBuiltIn($0) }
            .sorted { $0.modifiedAt > $1.modifiedAt }
    }
}

//
//  TrainingPlanManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import Foundation

@MainActor
@Observable
class TrainingPlanManager {
    
    private let local: LocalTrainingPlanPersistence
    private let remote: RemoteTrainingPlanService
    private var plansListener: (() -> Void)?
    private let workoutTemplateResolver: WorkoutTemplateResolver?
    
    private(set) var currentTrainingPlan: TrainingPlan?
    private(set) var allPlans: [TrainingPlan] = []
    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    
    init(services: TrainingPlanServices, workoutTemplateResolver: WorkoutTemplateResolver? = nil) {
        self.remote = services.remote
        self.local = services.local
        self.workoutTemplateResolver = workoutTemplateResolver
        self.currentTrainingPlan = local.getCurrentTrainingPlan()
        self.allPlans = local.getAllPlans()
    }
    
    // MARK: - Sync Listener
    
    func startSyncListener(userId: String) {
        // Stop existing listener if any
        stopSyncListener()
        
        plansListener = remote.addPlansListener(userId: userId) { [weak self] remotePlans in
            guard let self = self else { return }
            Task { @MainActor in
                self.mergeRemotePlans(remotePlans)
            }
        }
    }
    
    func stopSyncListener() {
        plansListener?()
        plansListener = nil
    }
    
    @MainActor
    func clearAllLocalData() throws {
        // Stop listener
        stopSyncListener()
        
        // Clear all local plans
        let planIds = allPlans.map { $0.planId }
        for planId in planIds {
            try local.deletePlan(id: planId)
        }
        
        // Clear state
        currentTrainingPlan = nil
        allPlans = []
    }
    
    @MainActor
    private func mergeRemotePlans(_ remotePlans: [TrainingPlan]) {
        // Get local plans
        let localPlans = local.getAllPlans()
        
        // Create a dictionary of local plans by ID for quick lookup
        var localPlanDict = Dictionary(uniqueKeysWithValues: localPlans.map { ($0.planId, $0) })
        
        // Merge logic: last-write-wins based on modifiedAt
        for remotePlan in remotePlans {
            if let localPlan = localPlanDict[remotePlan.planId] {
                // Compare timestamps and keep the newer one
                if remotePlan.modifiedAt > localPlan.modifiedAt {
                    try? local.savePlan(remotePlan)
                    localPlanDict[remotePlan.planId] = remotePlan
                }
            } else {
                // New plan from remote - save it locally
                try? local.savePlan(remotePlan)
                localPlanDict[remotePlan.planId] = remotePlan
            }
        }
        
        // Check for deletions (plans in local but not in remote)
        let remotePlanIds = Set(remotePlans.map { $0.planId })
        for localPlanId in localPlanDict.keys where !remotePlanIds.contains(localPlanId) {
            try? local.deletePlan(id: localPlanId)
            localPlanDict.removeValue(forKey: localPlanId)
        }
        
        // Update UI state
        allPlans = local.getAllPlans()
        currentTrainingPlan = local.getCurrentTrainingPlan()
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
        endDate: Date? = nil,
        userId: String,
        planName: String? = nil
    ) async throws -> TrainingPlan {
        // Use ProgramTemplateManager to instantiate
        let plan = instantiatePlanFromTemplate(template, userId: userId, startDate: startDate, endDate: endDate, planName: planName)
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
                workoutName: workout.workoutName,
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
        endDate: Date? = nil,
        planName: String?
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
                
                let workoutName = resolveWorkoutName(from: mapping)
                
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
    
    private func resolveWorkoutName(from mapping: DayWorkoutMapping) -> String? {
        if let name = mapping.workoutName {
            return name
        }
        guard let resolver = workoutTemplateResolver,
              let template = try? resolver.getLocalWorkoutTemplate(id: mapping.workoutTemplateId) else {
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
    
    // MARK: - Sync Operations
    
    func syncFromRemote(userId: String) async throws {
        isLoading = true
        error = nil
        
        do {
            let remotePlans = try await remote.fetchAllPlans(userId: userId)
            
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
    case noUserId
    
    var errorDescription: String? {
        switch self {
        case .noActivePlan:
            return "No active training plan"
        case .workoutNotFound:
            return "Scheduled workout not found"
        case .invalidData:
            return "Invalid data"
        case .noUserId:
            return "User ID not available"
        }
    }
}

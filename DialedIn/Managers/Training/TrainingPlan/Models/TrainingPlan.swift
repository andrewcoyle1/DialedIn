//
//  TrainingPlan.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import Foundation

struct TrainingPlan: Codable, Equatable, Identifiable {
    var id: String { planId }
    
    let planId: String
    let userId: String?
    let name: String
    let description: String?
    let startDate: Date
    let endDate: Date?
    let isActive: Bool
    let programTemplateId: String?
    
    var weeks: [TrainingWeek]
    var goals: [TrainingGoal]
    let createdAt: Date
    var modifiedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case planId = "plan_id"
        case userId = "user_id"
        case name
        case description
        case startDate = "start_date"
        case endDate = "end_date"
        case isActive = "is_active"
        case programTemplateId = "program_template_id"
        case weeks
        case goals
        case createdAt = "created_at"
        case modifiedAt = "modified_at"
    }
    
    init(
        planId: String,
        userId: String?,
        name: String,
        description: String? = nil,
        startDate: Date,
        endDate: Date? = nil,
        isActive: Bool = true,
        programTemplateId: String? = nil,
        weeks: [TrainingWeek] = [],
        goals: [TrainingGoal] = [],
        createdAt: Date,
        modifiedAt: Date
    ) {
        self.planId = planId
        self.userId = userId
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.programTemplateId = programTemplateId
        self.weeks = weeks
        self.goals = goals
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
    
    // Helper methods
    func currentWeek(on date: Date = .now) -> TrainingWeek? {
        let weeksSinceStart = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: date).weekOfYear ?? 0
        return weeks.first { $0.weekNumber == weeksSinceStart + 1 }
    }
    
    func weekProgress(for weekNumber: Int) -> WeekProgress {
        guard let week = weeks.first(where: { $0.weekNumber == weekNumber }) else {
            return WeekProgress(weekNumber: weekNumber, totalWorkouts: 0, completedWorkouts: 0, scheduledWorkouts: [])
        }
        
        let completed = week.scheduledWorkouts.filter { $0.isCompleted }.count
        return WeekProgress(
            weekNumber: weekNumber,
            totalWorkouts: week.scheduledWorkouts.count,
            completedWorkouts: completed,
            scheduledWorkouts: week.scheduledWorkouts
        )
    }
    
    var adherenceRate: Double {
        let allWorkouts = weeks.flatMap { $0.scheduledWorkouts }
        // Only consider workouts scheduled up to and including today
        let pastAndCurrentWorkouts = allWorkouts.filter { workout in
            guard let scheduledDate = workout.scheduledDate else { return false }
            return scheduledDate <= Date()
        }
        guard !pastAndCurrentWorkouts.isEmpty else { return 0 }
        let completed = pastAndCurrentWorkouts.filter { $0.isCompleted }.count
        return Double(completed) / Double(pastAndCurrentWorkouts.count)
    }
    
    mutating func updateWeek(_ week: TrainingWeek) {
        if let index = weeks.firstIndex(where: { $0.weekNumber == week.weekNumber }) {
            weeks[index] = week
            modifiedAt = .now
        }
    }
    
    mutating func addWeek(_ week: TrainingWeek) {
        weeks.append(week)
        modifiedAt = .now
    }
    
    mutating func updateGoal(_ goal: TrainingGoal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            modifiedAt = .now
        }
    }
    
    static func newPlan(name: String, userId: String, description: String? = nil, startDate: Date = .now) -> TrainingPlan {
        TrainingPlan(
            planId: UUID().uuidString,
            userId: userId,
            name: name,
            description: description,
            startDate: startDate,
            endDate: nil,
            isActive: true,
            programTemplateId: nil,
            weeks: [],
            goals: [],
            createdAt: .now,
            modifiedAt: .now
        )
    }
    
    static var mock: TrainingPlan {
        TrainingPlan(
            planId: "mock-plan-1",
            userId: "user-1",
            name: "Summer Strength Program",
            description: "8-week progressive strength building program",
            startDate: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: .now) ?? .now,
            endDate: Calendar.current.date(byAdding: .weekOfYear, value: 6, to: .now),
            isActive: true,
            programTemplateId: "template-ppl",
            weeks: TrainingWeek.mocks,
            goals: TrainingGoal.mocks,
            createdAt: Date(timeIntervalSinceNow: -86400 * 14),
            modifiedAt: .now
        )
    }
    
    // MARK: - Preview Mock Variations
    
    static var mockNoGoals: TrainingPlan {
        TrainingPlan(
            planId: "mock-plan-no-goals",
            userId: "user-1",
            name: "Basic Training Plan",
            description: "A simple training plan without specific goals",
            startDate: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: .now) ?? .now,
            endDate: Calendar.current.date(byAdding: .weekOfYear, value: 7, to: .now),
            isActive: true,
            programTemplateId: "template-basic",
            weeks: TrainingWeek.mocks,
            goals: [], // No goals
            createdAt: Date(timeIntervalSinceNow: -86400 * 7),
            modifiedAt: .now
        )
    }
    
    static var mockHighAdherence: TrainingPlan {
        // Create a new plan with high adherence data
        var highAdherenceWeeks = TrainingWeek.mocks
        for iteration in 0..<highAdherenceWeeks.count {
            highAdherenceWeeks[iteration].scheduledWorkouts = highAdherenceWeeks[iteration].scheduledWorkouts.map { workout in
                var modifiedWorkout = workout
                modifiedWorkout.isCompleted = true
                modifiedWorkout.completedSessionId = "session-\(iteration+1)"
                return modifiedWorkout
            }
        }
        
        return TrainingPlan(
            planId: "mock-plan-high-adherence",
            userId: "user-1",
            name: "Consistent Training Program",
            description: "High adherence training program",
            startDate: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: .now) ?? .now,
            endDate: Calendar.current.date(byAdding: .weekOfYear, value: 6, to: .now),
            isActive: true,
            programTemplateId: "template-ppl",
            weeks: highAdherenceWeeks,
            goals: TrainingGoal.mocks,
            createdAt: Date(timeIntervalSinceNow: -86400 * 14),
            modifiedAt: .now
        )
    }
    
    static var mockLowAdherence: TrainingPlan {
        // Create a new plan with low adherence data
        var lowAdherenceWeeks = TrainingWeek.mocks
        for iteration in 0..<lowAdherenceWeeks.count {
            lowAdherenceWeeks[iteration].scheduledWorkouts = lowAdherenceWeeks[iteration].scheduledWorkouts.enumerated().map { index, workout in
                var modifiedWorkout = workout
                // Only complete 1 out of 3 workouts per week
                modifiedWorkout.isCompleted = index % 3 == 0
                if modifiedWorkout.isCompleted {
                    modifiedWorkout.completedSessionId = "session-\(iteration+1)"
                }
                return modifiedWorkout
            }
        }
        
        return TrainingPlan(
            planId: "mock-plan-low-adherence",
            userId: "user-1",
            name: "Struggling Training Program",
            description: "Low adherence training program",
            startDate: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: .now) ?? .now,
            endDate: Calendar.current.date(byAdding: .weekOfYear, value: 6, to: .now),
            isActive: true,
            programTemplateId: "template-ppl",
            weeks: lowAdherenceWeeks,
            goals: TrainingGoal.mocks,
            createdAt: Date(timeIntervalSinceNow: -86400 * 14),
            modifiedAt: .now
        )
    }
    
    static var mockWithTodaysWorkout: TrainingPlan {
        
        // Add a workout for today
        let todaysWorkout = ScheduledWorkout.todayIncomplete
        var modifiedWeeks = TrainingWeek.mocks
        if !modifiedWeeks.isEmpty {
            modifiedWeeks[0].scheduledWorkouts.append(todaysWorkout)
        }
        
        return TrainingPlan(
            planId: "mock-plan-todays-workout",
            userId: "user-1",
            name: "Today's Workout Program",
            description: "Program with workout scheduled for today",
            startDate: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: .now) ?? .now,
            endDate: Calendar.current.date(byAdding: .weekOfYear, value: 6, to: .now),
            isActive: true,
            programTemplateId: "template-ppl",
            weeks: modifiedWeeks,
            goals: TrainingGoal.mocks,
            createdAt: Date(timeIntervalSinceNow: -86400 * 14),
            modifiedAt: .now
        )
    }
    
    static var mockWithCompletedTodaysWorkout: TrainingPlan {
        let todaysWorkout = ScheduledWorkout.todayComplete
        var modifiedWeeks = TrainingWeek.mocks
        if !modifiedWeeks.isEmpty {
            modifiedWeeks[0].scheduledWorkouts.append(todaysWorkout)
        }
        
        return TrainingPlan(
            planId: "mock-plan-completed-todays-workout",
            userId: "user-1",
            name: "Completed Today's Workout Program",
            description: "Program with today's workout already completed",
            startDate: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: .now) ?? .now,
            endDate: Calendar.current.date(byAdding: .weekOfYear, value: 6, to: .now),
            isActive: true,
            programTemplateId: "template-ppl",
            weeks: modifiedWeeks,
            goals: TrainingGoal.mocks,
            createdAt: Date(timeIntervalSinceNow: -86400 * 14),
            modifiedAt: .now
        )
    }
    
    static var mockWithMultipleTodaysWorkouts: TrainingPlan {
        let todaysWorkouts = ScheduledWorkout.todayMultiple
        var modifiedWeeks = TrainingWeek.mocks
        if !modifiedWeeks.isEmpty {
            modifiedWeeks[0].scheduledWorkouts.append(contentsOf: todaysWorkouts)
        }
        
        return TrainingPlan(
            planId: "mock-plan-multiple-todays-workouts",
            userId: "user-1",
            name: "Multiple Today's Workouts Program",
            description: "Program with multiple workouts scheduled for today",
            startDate: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: .now) ?? .now,
            endDate: Calendar.current.date(byAdding: .weekOfYear, value: 6, to: .now),
            isActive: true,
            programTemplateId: "template-ppl",
            weeks: modifiedWeeks,
            goals: TrainingGoal.mocks,
            createdAt: Date(timeIntervalSinceNow: -86400 * 14),
            modifiedAt: .now
        )
    }
    
    static var mockNearEnd: TrainingPlan {
        TrainingPlan(
            planId: "mock-plan-near-end",
            userId: "user-1",
            name: "Finishing Program",
            description: "Program ending soon",
            startDate: Calendar.current.date(byAdding: .day, value: -50, to: .now) ?? .now,
            endDate: Calendar.current.date(byAdding: .day, value: 3, to: .now), // Ends in 3 days
            isActive: true,
            programTemplateId: "template-finishing",
            weeks: TrainingWeek.mocks,
            goals: TrainingGoal.mocks,
            createdAt: Date(timeIntervalSinceNow: -86400 * 50),
            modifiedAt: .now
        )
    }
    
    static var mocks: [TrainingPlan] {
        return [
            self.mock,
            self.mockNoGoals,
            self.mockHighAdherence,
            self.mockLowAdherence,
            self.mockWithTodaysWorkout,
            self.mockWithCompletedTodaysWorkout,
            self.mockWithMultipleTodaysWorkouts,
            self.mockNearEnd
        ]
    }
}

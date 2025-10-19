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
        guard !allWorkouts.isEmpty else { return 0 }
        let completed = allWorkouts.filter { $0.isCompleted }.count
        return Double(completed) / Double(allWorkouts.count)
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
}

struct TrainingWeek: Codable, Equatable, Identifiable {
    var id: Int { weekNumber }
    
    let weekNumber: Int
    var scheduledWorkouts: [ScheduledWorkout]
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case weekNumber = "week_number"
        case scheduledWorkouts = "scheduled_workouts"
        case notes
    }
    
    init(weekNumber: Int, scheduledWorkouts: [ScheduledWorkout] = [], notes: String? = nil) {
        self.weekNumber = weekNumber
        self.scheduledWorkouts = scheduledWorkouts
        self.notes = notes
    }
    
    var completionRate: Double {
        guard !scheduledWorkouts.isEmpty else { return 0 }
        let completed = scheduledWorkouts.filter { $0.isCompleted }.count
        return Double(completed) / Double(scheduledWorkouts.count)
    }
    
    static var mocks: [TrainingWeek] {
        [
            TrainingWeek(weekNumber: 1, scheduledWorkouts: ScheduledWorkout.mocksWeek1, notes: "Focus on form"),
            TrainingWeek(weekNumber: 2, scheduledWorkouts: ScheduledWorkout.mocksWeek2, notes: "Increase intensity"),
            TrainingWeek(weekNumber: 3, scheduledWorkouts: ScheduledWorkout.mocksWeek3)
        ]
    }
}

struct ScheduledWorkout: Codable, Equatable, Identifiable {
    let id: String
    let workoutTemplateId: String
    let dayOfWeek: Int // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
    let scheduledDate: Date?
    var completedSessionId: String?
    var isCompleted: Bool
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case workoutTemplateId = "workout_template_id"
        case dayOfWeek = "day_of_week"
        case scheduledDate = "scheduled_date"
        case completedSessionId = "completed_session_id"
        case isCompleted = "is_completed"
        case notes
    }
    
    init(
        id: String = UUID().uuidString,
        workoutTemplateId: String,
        dayOfWeek: Int,
        scheduledDate: Date? = nil,
        completedSessionId: String? = nil,
        isCompleted: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.workoutTemplateId = workoutTemplateId
        self.dayOfWeek = dayOfWeek
        self.scheduledDate = scheduledDate
        self.completedSessionId = completedSessionId
        self.isCompleted = isCompleted
        self.notes = notes
    }
    
    var isPast: Bool {
        guard let date = scheduledDate else { return false }
        return date < Date()
    }
    
    var isMissed: Bool {
        isPast && !isCompleted
    }
    
    static var mocksWeek1: [ScheduledWorkout] {
        let today = Date()
        let calendar = Calendar.current
        return [
            ScheduledWorkout(
                workoutTemplateId: "workout1",
                dayOfWeek: 2,
                scheduledDate: calendar.date(byAdding: .day, value: -6, to: today),
                completedSessionId: "session1",
                isCompleted: true
            ),
            ScheduledWorkout(
                workoutTemplateId: "workout2",
                dayOfWeek: 4,
                scheduledDate: calendar.date(byAdding: .day, value: -4, to: today),
                completedSessionId: "session2",
                isCompleted: true
            ),
            ScheduledWorkout(
                workoutTemplateId: "workout3",
                dayOfWeek: 6,
                scheduledDate: calendar.date(byAdding: .day, value: -2, to: today),
                isCompleted: false
            )
        ]
    }
    
    static var mocksWeek2: [ScheduledWorkout] {
        let today = Date()
        let calendar = Calendar.current
        return [
            ScheduledWorkout(
                workoutTemplateId: "workout1",
                dayOfWeek: 2,
                scheduledDate: calendar.date(byAdding: .day, value: 1, to: today),
                isCompleted: false
            ),
            ScheduledWorkout(
                workoutTemplateId: "workout2",
                dayOfWeek: 4,
                scheduledDate: calendar.date(byAdding: .day, value: 3, to: today),
                isCompleted: false
            ),
            ScheduledWorkout(
                workoutTemplateId: "workout3",
                dayOfWeek: 6,
                scheduledDate: calendar.date(byAdding: .day, value: 5, to: today),
                isCompleted: false
            )
        ]
    }
    
    static var mocksWeek3: [ScheduledWorkout] {
        let today = Date()
        let calendar = Calendar.current
        return [
            ScheduledWorkout(
                workoutTemplateId: "workout1",
                dayOfWeek: 2,
                scheduledDate: calendar.date(byAdding: .day, value: 8, to: today),
                isCompleted: false
            ),
            ScheduledWorkout(
                workoutTemplateId: "workout2",
                dayOfWeek: 4,
                scheduledDate: calendar.date(byAdding: .day, value: 10, to: today),
                isCompleted: false
            ),
            ScheduledWorkout(
                workoutTemplateId: "workout3",
                dayOfWeek: 6,
                scheduledDate: calendar.date(byAdding: .day, value: 12, to: today),
                isCompleted: false
            )
        ]
    }
}

struct TrainingGoal: Codable, Equatable, Identifiable {
    let id: String
    let type: GoalType
    let targetValue: Double
    var currentValue: Double
    let targetDate: Date?
    let exerciseId: String? // Optional: specific to an exercise
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case targetValue = "target_value"
        case currentValue = "current_value"
        case targetDate = "target_date"
        case exerciseId = "exercise_id"
    }
    
    init(
        id: String = UUID().uuidString,
        type: GoalType,
        targetValue: Double,
        currentValue: Double = 0,
        targetDate: Date? = nil,
        exerciseId: String? = nil
    ) {
        self.id = id
        self.type = type
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.targetDate = targetDate
        self.exerciseId = exerciseId
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }
    
    var isCompleted: Bool {
        currentValue >= targetValue
    }
    
    static var mocks: [TrainingGoal] {
        [
            TrainingGoal(
                type: .strength,
                targetValue: 100,
                currentValue: 85,
                targetDate: Calendar.current.date(byAdding: .month, value: 2, to: .now),
                exerciseId: "1"
            ),
            TrainingGoal(
                type: .volume,
                targetValue: 50000,
                currentValue: 32000,
                targetDate: Calendar.current.date(byAdding: .month, value: 1, to: .now)
            ),
            TrainingGoal(
                type: .consistency,
                targetValue: 24,
                currentValue: 16,
                targetDate: Calendar.current.date(byAdding: .month, value: 2, to: .now)
            )
        ]
    }
}

enum GoalType: String, Codable, CaseIterable {
    case strength // Lift X kg on an exercise
    case volume // Total volume lifted
    case consistency // Workouts completed
    case frequency // Workouts per week
    case bodyweight // Target bodyweight
    
    var description: String {
        switch self {
        case .strength:
            return "Strength Goal"
        case .volume:
            return "Volume Goal"
        case .consistency:
            return "Consistency Goal"
        case .frequency:
            return "Frequency Goal"
        case .bodyweight:
            return "Bodyweight Goal"
        }
    }
    
    var unit: String {
        switch self {
        case .strength:
            return "kg"
        case .volume:
            return "kg"
        case .consistency:
            return "workouts"
        case .frequency:
            return "per week"
        case .bodyweight:
            return "kg"
        }
    }
}

struct WeekProgress: Equatable {
    let weekNumber: Int
    let totalWorkouts: Int
    let completedWorkouts: Int
    let scheduledWorkouts: [ScheduledWorkout]
    
    var completionRate: Double {
        guard totalWorkouts > 0 else { return 0 }
        return Double(completedWorkouts) / Double(totalWorkouts)
    }
    
    var missedWorkouts: Int {
        scheduledWorkouts.filter { $0.isMissed }.count
    }
}

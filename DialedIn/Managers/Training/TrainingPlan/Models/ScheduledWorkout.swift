//
//  ScheduledWorkout.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/12/2025.
//

import Foundation

struct ScheduledWorkout: Codable, Equatable, Identifiable {
    let id: String
    let workoutTemplateId: String
    let workoutName: String?
    let dayOfWeek: Int // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
    let scheduledDate: Date?
    var completedSessionId: String?
    var isCompleted: Bool
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case workoutTemplateId = "workout_template_id"
        case workoutName = "workout_name"
        case dayOfWeek = "day_of_week"
        case scheduledDate = "scheduled_date"
        case completedSessionId = "completed_session_id"
        case isCompleted = "is_completed"
        case notes
    }
    
    init(
        id: String = UUID().uuidString,
        workoutTemplateId: String,
        workoutName: String? = nil,
        dayOfWeek: Int,
        scheduledDate: Date? = nil,
        completedSessionId: String? = nil,
        isCompleted: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.workoutTemplateId = workoutTemplateId
        self.workoutName = workoutName
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
                completedSessionId: "session-1",
                isCompleted: true
            ),
            ScheduledWorkout(
                workoutTemplateId: "workout2",
                dayOfWeek: 4,
                scheduledDate: calendar.date(byAdding: .day, value: -4, to: today),
                completedSessionId: "session-2",
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
    
    // MARK: - Preview Mock Variations
    
    static var todayIncomplete: ScheduledWorkout {
        let today = Date()
        return ScheduledWorkout(
            workoutTemplateId: "workout-today",
            workoutName: "Push Day",
            dayOfWeek: Calendar.current.component(.weekday, from: today),
            scheduledDate: today,
            isCompleted: false
        )
    }
    
    static var todayComplete: ScheduledWorkout {
        let today = Date()
        return ScheduledWorkout(
            workoutTemplateId: "workout-today-complete",
            workoutName: "Pull Day",
            dayOfWeek: Calendar.current.component(.weekday, from: today),
            scheduledDate: today,
            completedSessionId: "session-1",
            isCompleted: true
        )
    }
    
    static var todayMultiple: [ScheduledWorkout] {
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        
        return [
            ScheduledWorkout(
                workoutTemplateId: "workout-morning",
                workoutName: "Morning Cardio",
                dayOfWeek: weekday,
                scheduledDate: today,
                completedSessionId: "session-1",
                isCompleted: true
            ),
            ScheduledWorkout(
                workoutTemplateId: "workout-afternoon",
                workoutName: "Strength Training",
                dayOfWeek: weekday,
                scheduledDate: today,
                isCompleted: false
            )
        ]
    }
}

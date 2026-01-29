//
//  TrainingWeek.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/12/2025.
//

import Foundation

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

//
//  WeekProgress.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/12/2025.
//

import Foundation

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

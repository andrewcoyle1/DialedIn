//
//  ScheduledWorkoutRowViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ScheduledWorkoutRowViewModel {
    let scheduledWorkout: ScheduledWorkout
    
    init(scheduledWorkout: ScheduledWorkout) {
        self.scheduledWorkout = scheduledWorkout
    }
    
    var statusIcon: String {
        if scheduledWorkout.isCompleted {
            return "checkmark.circle.fill"
        } else if scheduledWorkout.isMissed {
            return "exclamationmark.circle.fill"
        } else {
            return "circle"
        }
    }
    
    var statusColor: Color {
        if scheduledWorkout.isCompleted {
            return .green
        } else if scheduledWorkout.isMissed {
            return .red
        } else {
            return .gray
        }
    }
}

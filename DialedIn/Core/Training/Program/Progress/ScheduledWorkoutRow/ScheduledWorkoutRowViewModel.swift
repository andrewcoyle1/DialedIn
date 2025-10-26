//
//  ScheduledWorkoutRowViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

protocol ScheduledWorkoutRowInteractor {
    
}

extension CoreInteractor: ScheduledWorkoutRowInteractor { }

@Observable
@MainActor
class ScheduledWorkoutRowViewModel {
    private let interactor: ScheduledWorkoutRowInteractor
    
    let scheduledWorkout: ScheduledWorkout
    
    init(
        interactor: ScheduledWorkoutRowInteractor,
        scheduledWorkout: ScheduledWorkout
    ) {
        self.interactor = interactor
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

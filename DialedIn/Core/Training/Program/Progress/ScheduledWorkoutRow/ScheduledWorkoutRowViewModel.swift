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

    init(interactor: ScheduledWorkoutRowInteractor) {
        self.interactor = interactor
    }
    
    func statusIcon(scheduledWorkout: ScheduledWorkout) -> String {
        if scheduledWorkout.isCompleted {
            return "checkmark.circle.fill"
        } else if scheduledWorkout.isMissed {
            return "exclamationmark.circle.fill"
        } else {
            return "circle"
        }
    }
    
    func statusColor(scheduledWorkout: ScheduledWorkout) -> Color {
        if scheduledWorkout.isCompleted {
            return .green
        } else if scheduledWorkout.isMissed {
            return .red
        } else {
            return .gray
        }
    }
}

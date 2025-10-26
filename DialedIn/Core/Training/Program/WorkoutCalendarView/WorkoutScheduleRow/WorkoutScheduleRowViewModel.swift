//
//  WorkoutScheduleRowViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

protocol WorkoutScheduleRowInteractor {
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel
}

extension CoreInteractor: WorkoutScheduleRowInteractor { }

@Observable
@MainActor
class WorkoutScheduleRowViewModel {
    private let interactor: WorkoutScheduleRowInteractor
    
    let workout: ScheduledWorkout
    var showAlert: AnyAppAlert?
    private(set) var templateName: String = "Workout"
    
    init(
        interactor: WorkoutScheduleRowInteractor,
        workout: ScheduledWorkout
    ) {
        self.interactor = interactor
        self.workout = workout
    }
    
    var statusIcon: String {
        if workout.isCompleted {
            return "checkmark.circle.fill"
        } else if workout.isMissed {
            return "exclamationmark.circle.fill"
        } else {
            return "circle"
        }
    }
    
    var statusColor: Color {
        if workout.isCompleted {
            return .green
        } else if workout.isMissed {
            return .red
        } else {
            return .orange
        }
    }
    
    func loadTemplateName() async throws {
        templateName = try await interactor.getWorkoutTemplate(id: workout.workoutTemplateId).name
    }
}

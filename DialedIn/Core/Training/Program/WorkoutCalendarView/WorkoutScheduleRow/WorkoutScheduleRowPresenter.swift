//
//  WorkoutScheduleRowPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutScheduleRowPresenter {
    private let interactor: WorkoutScheduleRowInteractor
    private let router: WorkoutScheduleRowRouter

    private(set) var templateName: String = "Workout"
    
    init(
        interactor: WorkoutScheduleRowInteractor,
        router: WorkoutScheduleRowRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func statusIcon(workout: ScheduledWorkout) -> String {
        if workout.isCompleted {
            return "checkmark.circle.fill"
        } else if workout.isMissed {
            return "exclamationmark.circle.fill"
        } else {
            return "circle"
        }
    }
    
    func statusColor(workout: ScheduledWorkout) -> Color {
        if workout.isCompleted {
            return .green
        } else if workout.isMissed {
            return .red
        } else {
            return .orange
        }
    }
    
    func loadTemplateName(workout: ScheduledWorkout) async {
        do {
            templateName = try await interactor.getWorkoutTemplate(id: workout.workoutTemplateId).name
        } catch {
            router.showAlert(error: error)
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}

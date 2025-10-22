//
//  TodaysWorkoutCardViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TodaysWorkoutCardViewModel {
    private let workoutTemplateManager: WorkoutTemplateManager
    let scheduledWorkout: ScheduledWorkout
    let onStart: () -> Void
    
    private(set) var templateName: String = "Workout"
    private(set) var exerciseCount: Int = 0
    var showAlert: AnyAppAlert?
    
    init(
        container: DependencyContainer,
        scheduledWorkout: ScheduledWorkout,
        onStart: @escaping () -> Void
    ) {
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.scheduledWorkout = scheduledWorkout
        self.onStart = onStart
    }
    
    func loadDetails() async {
        do {
            try await self.loadWorkoutDetails()
        } catch {
            self.showAlert = AnyAppAlert(error: error)
        }
    }
    
    func loadWorkoutDetails() async throws {
        let template = try await workoutTemplateManager.getWorkoutTemplate(id: scheduledWorkout.workoutTemplateId)
            templateName = template.name
            exerciseCount = template.exercises.count
        
    }
}

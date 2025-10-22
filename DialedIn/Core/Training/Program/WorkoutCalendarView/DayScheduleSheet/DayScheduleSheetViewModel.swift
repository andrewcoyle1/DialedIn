//
//  DayScheduleSheetViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class DayScheduleSheetViewModel {
    let workoutSessionManager: WorkoutSessionManager
    let date: Date
    let scheduledWorkouts: [ScheduledWorkout]
    let onStartWorkout: (ScheduledWorkout) async throws -> Void
    var sessionToShow: WorkoutSessionModel?
    var showAlert: AnyAppAlert?
    
    init(
        container: DependencyContainer,
        date: Date,
        scheduledWorkouts: [ScheduledWorkout],
        onStartWorkout: @escaping (ScheduledWorkout) async throws -> Void
    ) {
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.date = date
        self.scheduledWorkouts = scheduledWorkouts
        self.onStartWorkout = onStartWorkout
    }
    
    func openCompletedSession(for workout: ScheduledWorkout) async {
        guard let sessionId = workout.completedSessionId else { return }
        do {
            let session = try await workoutSessionManager.getWorkoutSession(id: sessionId)
            await MainActor.run {
                sessionToShow = session
            }
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
}

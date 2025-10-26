//
//  DayScheduleSheetViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

protocol DayScheduleScheetInteractor {
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel
}

extension CoreInteractor: DayScheduleScheetInteractor { }

@Observable
@MainActor
class DayScheduleSheetViewModel {
    let interactor: DayScheduleScheetInteractor
    let date: Date
    let scheduledWorkouts: [ScheduledWorkout]
    let onStartWorkout: (ScheduledWorkout) async throws -> Void
    var sessionToShow: WorkoutSessionModel?
    var showAlert: AnyAppAlert?
    
    init(
        interactor: DayScheduleScheetInteractor,
        date: Date,
        scheduledWorkouts: [ScheduledWorkout],
        onStartWorkout: @escaping (ScheduledWorkout) async throws -> Void
    ) {
        self.interactor = interactor
        self.date = date
        self.scheduledWorkouts = scheduledWorkouts
        self.onStartWorkout = onStartWorkout
    }
    
    func openCompletedSession(for workout: ScheduledWorkout) async {
        guard let sessionId = workout.completedSessionId else { return }
        do {
            let session = try await interactor.getWorkoutSession(id: sessionId)
            await MainActor.run {
                sessionToShow = session
            }
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
}

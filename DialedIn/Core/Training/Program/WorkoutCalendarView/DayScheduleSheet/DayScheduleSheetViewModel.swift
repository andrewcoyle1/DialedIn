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
    var sessionToShow: WorkoutSessionModel?
    var showAlert: AnyAppAlert?
    
    init(interactor: DayScheduleScheetInteractor) {
        self.interactor = interactor
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

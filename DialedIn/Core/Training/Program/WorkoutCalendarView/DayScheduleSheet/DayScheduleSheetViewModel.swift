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

@MainActor
protocol DayScheduleSheetRouter {
    func showDevSettingsView()
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailViewDelegate)
}

extension CoreRouter: DayScheduleSheetRouter { }

@Observable
@MainActor
class DayScheduleSheetViewModel {
    private let interactor: DayScheduleScheetInteractor
    private let router: DayScheduleSheetRouter

    var sessionToShow: WorkoutSessionModel?
    var showAlert: AnyAppAlert?
    
    init(
        interactor: DayScheduleScheetInteractor,
        router: DayScheduleSheetRouter
    ) {
        self.interactor = interactor
        self.router = router
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

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func onWorkoutSessionPressed(session: WorkoutSessionModel) {
        router.showWorkoutSessionDetailView(delegate: WorkoutSessionDetailViewDelegate(workoutSession: session))
    }
}

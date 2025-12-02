//
//  DayScheduleSheetPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class DayScheduleSheetPresenter {
    private let interactor: DayScheduleScheetInteractor
    private let router: DayScheduleSheetRouter

    var sessionToShow: WorkoutSessionModel?

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
            router.showAlert(error: error)
        }
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func onWorkoutSessionPressed(session: WorkoutSessionModel) {
        router.showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate(workoutSession: session))
    }
}

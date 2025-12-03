//
//  WorkoutsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutsPresenter {
    
    private let interactor: WorkoutsInteractor
    private let router: WorkoutsRouter
    
    init(
        interactor: WorkoutsInteractor,
        router: WorkoutsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onWorkoutPressed(workout: WorkoutTemplateModel) {
        // Only increment click count for non-system workouts
        // System workouts (IDs starting with "system-") are read-only
        if !workout.id.hasPrefix("system-") {
            Task {
                interactor.trackEvent(event: Event.incrementWorkoutStart)
                do {
                    try await interactor.incrementWorkoutTemplateInteraction(id: workout.id)
                    interactor.trackEvent(event: Event.incrementWorkoutSuccess)
                } catch {
                    interactor.trackEvent(event: Event.incrementWorkoutFail(error: error))
                }
            }
        }
        router.showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate(workoutTemplate: workout))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case incrementWorkoutStart
        case incrementWorkoutSuccess
        case incrementWorkoutFail(error: Error)

        var eventName: String {
            switch self {
            case .incrementWorkoutStart:              return "WorkoutsView_IncrementWorkout_Start"
            case .incrementWorkoutSuccess:            return "WorkoutsView_IncrementWorkout_Success"
            case .incrementWorkoutFail:               return "WorkoutsView_IncrementWorkout_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .incrementWorkoutFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .incrementWorkoutFail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}

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
    
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onWorkoutPressed(workout: WorkoutTemplateModel) {
        router.showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate(workoutTemplate: workout))
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

//
//  TodaysWorkoutCardPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TodaysWorkoutCardPresenter {
    private let interactor: TodaysWorkoutCardInteractor
    private let router: TodaysWorkoutCardRouter

    private(set) var templateName: String = "Workout"
    private(set) var exerciseCount: Int = 0
    private(set) var isLoading: Bool = true

    init(
        interactor: TodaysWorkoutCardInteractor,
        router: TodaysWorkoutCardRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadWorkoutDetails(scheduledWorkout: ScheduledWorkout) async {
        interactor.trackEvent(event: Event.loadWorkoutStart)
        do {
            let template = try await interactor.getWorkoutTemplate(id: scheduledWorkout.workoutTemplateId)
                templateName = template.name
                exerciseCount = template.exercises.count
            interactor.trackEvent(event: Event.loadWorkoutSuccess)
            isLoading = false
        } catch {
            interactor.trackEvent(event: Event.loadWorkoutFailure(error: error))
            self.router.showAlert(error: error)
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case loadWorkoutStart
        case loadWorkoutSuccess
        case loadWorkoutFailure(error: Error)
        
        var eventName: String {
            switch self {
            case .loadWorkoutStart:     return "TodaysWorkoutView_LoadWorkout_Start"
            case .loadWorkoutSuccess:   return "TodaysWorkoutView_LoadWorkout_Success"
            case .loadWorkoutFailure:   return "TodaysWorkoutView_LoadWorkout_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadWorkoutFailure(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
                
            }
        }
    }
}

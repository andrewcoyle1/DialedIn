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
    private let logManager: LogManager
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
        self.logManager = container.resolve(LogManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.scheduledWorkout = scheduledWorkout
        self.onStart = onStart
    }
    
    func loadWorkoutDetails() async {
        logManager.trackEvent(event: Event.loadWorkoutStart)
        do {
            let template = try await workoutTemplateManager.getWorkoutTemplate(id: scheduledWorkout.workoutTemplateId)
                templateName = template.name
                exerciseCount = template.exercises.count
            logManager.trackEvent(event: Event.loadWorkoutSuccess)

        } catch {
            logManager.trackEvent(event: Event.loadWorkoutFailure(error: error))
            self.showAlert = AnyAppAlert(error: error)
        }
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

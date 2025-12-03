//
//  ThisWeeksWorkoutsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

import SwiftUI

@Observable
@MainActor
class ThisWeeksWorkoutsPresenter {
    private let interactor: ThisWeeksWorkoutsInteractor
    private let router: ThisWeeksWorkoutsRouter
    
    var isExpanded: Bool = true
    
    init(
        interactor: ThisWeeksWorkoutsInteractor,
        router: ThisWeeksWorkoutsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onSectionToggled() {
        withAnimation(.easeInOut) {
            isExpanded.toggle()
        }
    }
    
    func getWorkoutsForDay(_ day: Date, calendar: Calendar) -> [ScheduledWorkout] {
        (interactor.currentTrainingPlan?.weeks.flatMap { $0.scheduledWorkouts } ?? [])
            .filter { workout in
                guard let scheduled = workout.scheduledDate else { return false }
                return calendar.isDate(scheduled, inSameDayAs: day)
            }
            .sorted { ($0.scheduledDate ?? .distantFuture) < ($1.scheduledDate ?? .distantFuture) }
    }
    
    func startWorkout(_ scheduledWorkout: ScheduledWorkout) async {
        interactor.trackEvent(event: Event.startWorkoutRequestedStart)
        do {
            let template = try await interactor.getWorkoutTemplate(id: scheduledWorkout.workoutTemplateId)
            
            // Small delay to ensure any pending presentations complete
            try? await Task.sleep(for: .seconds(0.1))
            
            // Notify parent to show WorkoutStartView
            handleWorkoutStartRequest(template: template, scheduledWorkout: scheduledWorkout)
            interactor.trackEvent(event: Event.startWorkoutRequestedSuccess)

        } catch {
            interactor.trackEvent(event: Event.startWorkoutRequestedFail(error: error))
            self.router.showAlert(error: error)
        }
    }
    
    private func handleWorkoutStartRequest(template: WorkoutTemplateModel, scheduledWorkout: ScheduledWorkout?) {
        router.showWorkoutStartView(delegate: WorkoutStartDelegate(template: template, scheduledWorkout: scheduledWorkout))
    }
    
    func openCompletedSession(for scheduledWorkout: ScheduledWorkout) {
        guard let sessionId = scheduledWorkout.completedSessionId else { return }
        interactor.trackEvent(event: Event.openCompletedSessionStart)
        do {
            let session = try interactor.getLocalWorkoutSession(id: sessionId)
            router.showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate(workoutSession: session))
            interactor.trackEvent(event: Event.openCompletedSessionSuccess)
        } catch {
            router.showAlert(error: error)
            interactor.trackEvent(event: Event.openCompletedSessionFail(error: error))
        }
    }

    enum Event: LoggableEvent {
        case startWorkoutRequestedStart
        case startWorkoutRequestedSuccess
        case startWorkoutRequestedFail(error: Error)
        case openCompletedSessionStart
        case openCompletedSessionSuccess
        case openCompletedSessionFail(error: Error)

        var eventName: String {
            switch self {
            case .startWorkoutRequestedStart:    return "ProgramView_StartWorkoutRequested_Start"
            case .startWorkoutRequestedSuccess:  return "ProgramView_StartWorkoutRequested_Success"
            case .startWorkoutRequestedFail:     return "ProgramView_StartWorkoutRequested_Fail"
            case .openCompletedSessionStart:     return "ProgramView_OpenCompletedSession_Start"
            case .openCompletedSessionSuccess:   return "ProgramView_OpenCompletedSession_Success"
            case .openCompletedSessionFail:      return "ProgramView_OpenCompletedSession_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .startWorkoutRequestedFail(error: let error), .openCompletedSessionFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .startWorkoutRequestedFail, .openCompletedSessionFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }

}

//
//  WorkoutCalendarViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

protocol WorkoutCalendarInteractor {
    var currentTrainingPlan: TrainingPlan? { get }
    func trackEvent(event: LoggableEvent)
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel
}

extension CoreInteractor: WorkoutCalendarInteractor { }

@Observable
@MainActor
class WorkoutCalendarViewModel {
    
    private let interactor: WorkoutCalendarInteractor
    
    private let onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)?
    private let onWorkoutStartRequested: ((WorkoutTemplateModel, ScheduledWorkout?) -> Void)?

    var isShowingCalendar: Bool = true
    var collapsedSubtitle: String = "No sessions planned yet — tap to plan"
    private(set) var scheduledWorkouts: [ScheduledWorkout] = []
    var selectedDate: Date?
    var showWorkoutMenu: Bool = false
    private(set) var workoutsForMenu: [ScheduledWorkout] = []
    var showAlert: AnyAppAlert?
    
    var trainingPlan: TrainingPlan? {
        interactor.currentTrainingPlan
    }
    
    init(
        interactor: WorkoutCalendarInteractor,
        onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)? = nil,
        onWorkoutStartRequested: ((WorkoutTemplateModel, ScheduledWorkout?) -> Void)? = nil
    ) {
        self.interactor = interactor
        self.onSessionSelectionChanged = onSessionSelectionChanged
        self.onWorkoutStartRequested = onWorkoutStartRequested
    }
    
    func onCalendarToggled() {
        withAnimation(.easeInOut) {
            isShowingCalendar.toggle()
        }
    }
    
    func loadScheduledWorkouts() {
        guard let plan = interactor.currentTrainingPlan else {
            scheduledWorkouts = []
            return
        }
        scheduledWorkouts = plan.weeks.flatMap { $0.scheduledWorkouts }
    }
    
    func workoutsForDate(_ date: Date) -> [ScheduledWorkout] {
        let calendar = Calendar.current
        return scheduledWorkouts.filter { workout in
            guard let scheduledDate = workout.scheduledDate else { return false }
            return calendar.isDate(scheduledDate, inSameDayAs: date)
        }
    }
    
    func handleDateTapped(_ date: Date) {
        selectedDate = date
        let workouts = workoutsForDate(date)
        
        if workouts.isEmpty {
            return
        } else if workouts.count == 1 {
            // Single workout - handle directly
            Task {
                await handleWorkoutSelection(workouts[0])
            }
        } else {
            // Multiple workouts - show menu
            workoutsForMenu = workouts
            showWorkoutMenu = true
        }
    }
    
    func handleWorkoutSelection(_ workout: ScheduledWorkout) async {
        if workout.isCompleted {
            await openCompletedSession(for: workout)
        } else {
            await startWorkout(workout)
        }
    }
    
    func startWorkout(_ scheduledWorkout: ScheduledWorkout) async {
        interactor.trackEvent(event: Event.startWorkoutStart)
        do {
            let template = try await interactor.getWorkoutTemplate(id: scheduledWorkout.workoutTemplateId)
            
            // Small delay to ensure any pending presentations complete
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            // Notify parent to show WorkoutStartView
            onWorkoutStartRequested?(template, scheduledWorkout)
            interactor.trackEvent(event: Event.startWorkoutSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            interactor.trackEvent(event: Event.startWorkoutFail(error: error))
        }
    }
    
    func openCompletedSession(for scheduledWorkout: ScheduledWorkout) async {
        guard let sessionId = scheduledWorkout.completedSessionId else { return }
        interactor.trackEvent(event: Event.openCompletedSessionStart)
        do {
            let session = try await interactor.getWorkoutSession(id: sessionId)
            await MainActor.run {
                onSessionSelectionChanged?(session)
                interactor.trackEvent(event: Event.openCompletedSessionSuccess)
            }
        } catch {
            showAlert = AnyAppAlert(error: error)
            interactor.trackEvent(event: Event.openCompletedSessionFail(error: error))
        }
    }
    
    enum Event: LoggableEvent {
        case startWorkoutStart
        case startWorkoutSuccess
        case startWorkoutFail(error: Error)
        case openCompletedSessionStart
        case openCompletedSessionSuccess
        case openCompletedSessionFail(error: Error)
        
        var eventName: String {
            switch self {
            case .startWorkoutStart:    return "WorkoutCalendar_StartWorkout_Start"
            case .startWorkoutSuccess:  return "WorkoutCalendar_StartWorkout_Success"
            case .startWorkoutFail:  return "WorkoutCalendar_StartWorkout_Fail"
            case .openCompletedSessionStart:    return "WorkoutCalendar_OpenCompletedSession_Start"
            case .openCompletedSessionSuccess:  return "WorkoutCalendar_OpenCompletedSession_Success"
            case .openCompletedSessionFail:  return "WorkoutCalendar_OpenCompletedSession_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .startWorkoutFail(error: let error), .openCompletedSessionFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .startWorkoutFail, .openCompletedSessionFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}

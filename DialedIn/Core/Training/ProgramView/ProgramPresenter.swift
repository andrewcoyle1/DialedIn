//
//  ProgramPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramPresenter {
    
    private let interactor: ProgramInteractor
    private let router: ProgramRouter

    private let onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)?

    private(set) var collapsedSubtitle: String = "No sessions planned yet — tap to plan"

    private(set) var isShowingAddGoals: Bool = false
    var selectedHistorySession: WorkoutSessionModel?
    var activeSheet: ActiveSheet?

    var currentTrainingPlan: TrainingPlan? {
        interactor.currentTrainingPlan
    }
    
    var adherenceRate: Double {
        interactor.getAdherenceRate()
    }
    
    var currentWeek: TrainingWeek? {
        interactor.getCurrentWeek()
    }
    
    var upcomingWorkouts: [ScheduledWorkout] {
        interactor.getUpcomingWorkouts(limit: 5)
    }
    
    var todaysWorkouts: [ScheduledWorkout] {
        interactor.getTodaysWorkouts()
    }
    
    var navigationSubtitle: String {
        if let plan = interactor.currentTrainingPlan {
            let todaysWorkouts = interactor.getTodaysWorkouts()
            if !todaysWorkouts.isEmpty {
                let completedCount = todaysWorkouts.filter { $0.isCompleted }.count
                if completedCount == todaysWorkouts.count {
                    return "\(plan.name) • Today's workout complete ✓"
                } else {
                    return "\(plan.name) • Workout scheduled for today"
                }
            }
            
            let upcomingCount = interactor.getUpcomingWorkouts(limit: 1).count
            if upcomingCount > 0 {
                return "\(plan.name) • Next workout scheduled"
            } else {
                return plan.name
            }
        }
        return ""
    }
    
    init(
        interactor: ProgramInteractor,
        router: ProgramRouter,
        onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)? = nil
    ) {
        self.interactor = interactor
        self.router = router
        self.onSessionSelectionChanged = onSessionSelectionChanged
    }

    func getWeeklyProgress(weekNumber: Int) -> WeekProgress {
        interactor.trackEvent(event: Event.getWeeklyProgress)
        return interactor.getWeeklyProgress(for: weekNumber)
    }
    
    func getWorkoutsForDay(_ day: Date, calendar: Calendar) -> [ScheduledWorkout] {
        (interactor.currentTrainingPlan?.weeks.flatMap { $0.scheduledWorkouts } ?? [])
            .filter { workout in
                guard let scheduled = workout.scheduledDate else { return false }
                return calendar.isDate(scheduled, inSameDayAs: day)
            }
            .sorted { ($0.scheduledDate ?? .distantFuture) < ($1.scheduledDate ?? .distantFuture) }
    }
    
    func adherenceColor(_ rate: Double) -> Color {
        if rate >= 0.8 { return .green }
        if rate >= 0.6 { return .orange }
        return .red
    }
    
    func progressValue(start: Date, end: Date) -> Double {
        let total = end.timeIntervalSince(start)
        let elapsed = Date().timeIntervalSince(start)
        return min(max(elapsed / total, 0), 1)
    }
    
    func currentWeekNumber(start: Date) -> Int {
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: start, to: .now).weekOfYear ?? 0
        return weeks + 1
    }
    
    func totalWeeks(start: Date, end: Date) -> Int {
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: start, to: end).weekOfYear ?? 0
        return weeks + 1
    }
    
    func daysRemaining(until date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: .now, to: date).day ?? 0
        if days == 0 {
            return "Ends today"
        } else if days == 1 {
            return "1 day left"
        } else {
            return "\(days) days left"
        }
    }
    
    func handleWorkoutStartRequest(template: WorkoutTemplateModel, scheduledWorkout: ScheduledWorkout?) {
        router.showWorkoutStartView(delegate: WorkoutStartDelegate(template: template, scheduledWorkout: scheduledWorkout))
    }
    
    func handleSessionSelectionChanged(_ session: WorkoutSessionModel) {
        onSessionSelectionChanged?(session)
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

    func openCompletedSession(for scheduledWorkout: ScheduledWorkout) {
        guard let sessionId = scheduledWorkout.completedSessionId else { return }
        interactor.trackEvent(event: Event.openCompletedSessionStart)
        do {
            let session = try interactor.getLocalWorkoutSession(id: sessionId)
                selectedHistorySession = session
                onSessionSelectionChanged?(session)
            interactor.trackEvent(event: Event.openCompletedSessionSuccess)
        } catch {
            router.showAlert(error: error)
            interactor.trackEvent(event: Event.openCompletedSessionFail(error: error))
        }
    }
    
    // MARK: - Data Loading
    
    func loadData() async {
        interactor.trackEvent(event: Event.loadDataStart)
        do {
            try await interactor.syncFromRemote()
            interactor.trackEvent(event: Event.loadDataSuccess)
        } catch {
            interactor.trackEvent(event: Event.loadDataFail(error: error))
        }
    }
    
    func refreshData() async {
        interactor.trackEvent(event: Event.refreshDataStart)
        do {
            try await interactor.syncFromRemote()
            interactor.trackEvent(event: Event.refreshDataSuccess)
        } catch {
            interactor.trackEvent(event: Event.refreshDataFail(error: error))
            router.showAlert(error: error)
        }
    }

    func onProgramManagementPressed() {
        router.showProgramManagementView()
    }

    func onProgessDashboardPressed() {
        router.showProgressDashboardView()
    }

    func onStrengthProgressPressed() {
        router.showStrengthProgressView()
    }

    func onWorkoutHeatmapPressed() {
        router.showWorkoutHeatmapView()
    }

    func onAddGoalPressed() {
        guard let plan = currentTrainingPlan else { return }
        router.showAddGoalView(delegate: AddGoalDelegate(plan: plan))
    }
    
    func onChooseProgramPressed() {
        router.showProgramManagementView()
    }

    enum Event: LoggableEvent {
        case setActiveSheet(sheet: ActiveSheet)
        case startWorkoutRequestedStart
        case startWorkoutRequestedSuccess
        case startWorkoutRequestedFail(error: Error)
        case openCompletedSessionStart
        case openCompletedSessionSuccess
        case openCompletedSessionFail(error: Error)
        case loadDataStart
        case loadDataSuccess
        case loadDataFail(error: Error)
        case refreshDataStart
        case refreshDataSuccess
        case refreshDataFail(error: Error)
        case getWeeklyProgress

        var eventName: String {
            switch self {
            case .setActiveSheet:                return "ProgramView_SetActiveSheet"
            case .startWorkoutRequestedStart:    return "ProgramView_StartWorkoutRequested_Start"
            case .startWorkoutRequestedSuccess:  return "ProgramView_StartWorkoutRequested_Success"
            case .startWorkoutRequestedFail:     return "ProgramView_StartWorkoutRequested_Fail"
            case .openCompletedSessionStart:     return "ProgramView_OpenCompletedSession_Start"
            case .openCompletedSessionSuccess:   return "ProgramView_OpenCompletedSession_Success"
            case .openCompletedSessionFail:      return "ProgramView_OpenCompletedSession_Fail"
            case .loadDataStart:                 return "ProgramView_LoadData_Start"
            case .loadDataSuccess:               return "ProgramView_LoadData_Success"
            case .loadDataFail:                  return "ProgramView_LoadData_Fail"
            case .refreshDataStart:              return "ProgramView_RefreshData_Start"
            case .refreshDataSuccess:            return "ProgramView_RefreshData_Success"
            case .refreshDataFail:               return "ProgramView_RefreshData_Fail"
            case .getWeeklyProgress:             return "ProgramView_GetWeeklyProgress"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .setActiveSheet(sheet: let sheet):
                return sheet.eventParameters
            case .loadDataFail(error: let error), .refreshDataFail(error: let error), .startWorkoutRequestedFail(error: let error), .openCompletedSessionFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadDataFail, .refreshDataFail, .startWorkoutRequestedFail, .openCompletedSessionFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}

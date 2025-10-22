//
//  ProgramViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramViewModel {
    
    private let authManager: AuthManager
    private let logManager: LogManager
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let workoutTemplateManager: WorkoutTemplateManager
    private let workoutSessionManager: WorkoutSessionManager
    private let trainingPlanManager: TrainingPlanManager
    private let programTemplateManager: ProgramTemplateManager
    private let onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)?
    private let onWorkoutStartRequested: ((WorkoutTemplateModel, ScheduledWorkout?) -> Void)?
    private let onActiveSheetChanged: ((ActiveSheet?) -> Void)?
    
    private(set) var selectedWorkoutTemplate: WorkoutTemplateModel?
    private(set) var selectedExerciseTemplate: ExerciseTemplateModel?
    private(set) var isShowingCalendar: Bool = true
    private(set) var collapsedSubtitle: String = "No sessions planned yet — tap to plan"

    var selectedHistorySession: WorkoutSessionModel?
    var activeSheet: ActiveSheet?
    var showAlert: AnyAppAlert?
    
    var currentTrainingPlan: TrainingPlan? {
        trainingPlanManager.currentTrainingPlan
    }
    
    var adherenceRate: Double {
        trainingPlanManager.getAdherenceRate()
    }
    
    var currentWeek: TrainingWeek? {
        trainingPlanManager.getCurrentWeek()
    }
    
    var upcomingWorkouts: [ScheduledWorkout] {
        trainingPlanManager.getUpcomingWorkouts()
    }
    
    var todaysWorkouts: [ScheduledWorkout] {
        trainingPlanManager.getTodaysWorkouts()
    }
    
    var navigationSubtitle: String {
        if let plan = trainingPlanManager.currentTrainingPlan {
            let todaysWorkouts = trainingPlanManager.getTodaysWorkouts()
            if !todaysWorkouts.isEmpty {
                let completedCount = todaysWorkouts.filter { $0.isCompleted }.count
                if completedCount == todaysWorkouts.count {
                    return "\(plan.name) • Today's workout complete ✓"
                } else {
                    return "\(plan.name) • Workout scheduled for today"
                }
            }
            
            let upcomingCount = trainingPlanManager.getUpcomingWorkouts(limit: 1).count
            if upcomingCount > 0 {
                return "\(plan.name) • Next workout scheduled"
            } else {
                return plan.name
            }
        }
        return ""
    }
    init(
        container: DependencyContainer,
        onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)? = nil,
        onWorkoutStartRequested: ((WorkoutTemplateModel, ScheduledWorkout?) -> Void)? = nil,
        onActiveSheetChanged: ((ActiveSheet?) -> Void)? = nil
    ) {
        self.authManager = container.resolve(AuthManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.programTemplateManager = container.resolve(ProgramTemplateManager.self)!
        self.onSessionSelectionChanged = onSessionSelectionChanged
        self.onWorkoutStartRequested = onWorkoutStartRequested
        self.onActiveSheetChanged = onActiveSheetChanged
    }
    
    func setActiveSheet(_ activeSheet: ActiveSheet) {
        self.activeSheet = activeSheet
        onActiveSheetChanged?(activeSheet)
        logManager.trackEvent(event: Event.setActiveSheet(sheet: activeSheet))
    }
    
    func getWeeklyProgress(weekNumber: Int) -> WeekProgress {
        logManager.trackEvent(event: Event.getWeeklyProgress)
        return trainingPlanManager.getWeeklyProgress(for: weekNumber)
    }
    
    func getWorkoutsForDay(_ day: Date, calendar: Calendar) -> [ScheduledWorkout] {
        (trainingPlanManager.currentTrainingPlan?.weeks.flatMap { $0.scheduledWorkouts } ?? [])
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
        onWorkoutStartRequested?(template, scheduledWorkout)
    }
    
    func startWorkout(_ scheduledWorkout: ScheduledWorkout) async {
        logManager.trackEvent(event: Event.startWorkoutRequestedStart)
        do {
            let template = try await workoutTemplateManager.getWorkoutTemplate(id: scheduledWorkout.workoutTemplateId)
            
            // Small delay to ensure any pending presentations complete
            try? await Task.sleep(for: .seconds(0.1))
            
            // Notify parent to show WorkoutStartView
            onWorkoutStartRequested?(template, scheduledWorkout)
            logManager.trackEvent(event: Event.startWorkoutRequestedSuccess)

        } catch {
            logManager.trackEvent(event: Event.startWorkoutRequestedFail(error: error))
            self.showAlert = AnyAppAlert(error: error)
        }
    }

    func openCompletedSession(for scheduledWorkout: ScheduledWorkout) {
        guard let sessionId = scheduledWorkout.completedSessionId else { return }
        logManager.trackEvent(event: Event.openCompletedSessionStart)
        do {
            let session = try workoutSessionManager.getLocalWorkoutSession(id: sessionId)
                selectedHistorySession = session
                onSessionSelectionChanged?(session)
                logManager.trackEvent(event: Event.openCompletedSessionSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            logManager.trackEvent(event: Event.openCompletedSessionFail(error: error))
        }
    }
    
    // MARK: - Data Loading
    
    private func ensureUserIdIsSet() {
        // Ensure userId is set in trainingPlanManager before syncing
        if let userId = try? authManager.getAuthId() {
            trainingPlanManager.setUserId(userId)
        }
    }
    
    func loadData() async {
        ensureUserIdIsSet()
        logManager.trackEvent(event: Event.loadDataStart)
        do {
            try await trainingPlanManager.syncFromRemote()
            logManager.trackEvent(event: Event.loadDataSuccess)
        } catch {
            logManager.trackEvent(event: Event.loadDataFail(error: error))
        }
    }
    
    func refreshData() async {
        ensureUserIdIsSet()
        logManager.trackEvent(event: Event.refreshDataStart)
        do {
            try await trainingPlanManager.syncFromRemote()
            logManager.trackEvent(event: Event.refreshDataSuccess)
        } catch {
            logManager.trackEvent(event: Event.refreshDataFail(error: error))
            showAlert = AnyAppAlert(error: error)
        }
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

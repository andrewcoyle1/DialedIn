//
//  TrainingPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

struct MicrocycleItem: Identifiable {
    let id: String
    let dayPlan: WorkoutTemplateModel
    let completedSessionId: String?
    
    var isCompleted: Bool {
        completedSessionId != nil
    }
}

struct MicrocycleWorkoutTemplateModelItem: Identifiable {
    let id: String
    let date: Date
    let dayPlan: WorkoutTemplateModel
    let completedSessionId: String?
    
    var isCompleted: Bool {
        completedSessionId != nil
    }
}

@Observable
@MainActor
class TrainingPresenter {
    
    let interactor: TrainingInteractor
    let router: TrainingRouter
    
    let calendar = Calendar.current
    var microcycleHeaderText: String = "Current Microcycle"

    var activeProgramisExpanded: Bool = true
    var selectedDate: Date = Date()
    var selectedTime: Date = Date()
    
    var today: Date = Date()
    
    var favouriteGymProfile: GymProfileModel? {
        interactor.favouriteGymProfile
    }
    
    var workoutSessions: [WorkoutSessionModel] {
        interactor.workoutSessions
    }
    
    init(
        interactor: TrainingInteractor,
        router: TrainingRouter
    ) {
        self.interactor = interactor
        self.router = router
        
        // Normalize dates to start-of-day for reliable equality comparisons
        let normalizedToday = Date().startOfDay
        self.today = normalizedToday
        self.selectedDate = normalizedToday
    }
    
    func onViewAppear(delegate: TrainingDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: TrainingDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var activeTrainingProgram: TrainingProgram? {
        interactor.activeTrainingProgram
    }

    var userImageUrl: String? {
        interactor.userImageUrl
    }
    
    var activeSession: WorkoutSessionModel? {
        interactor.activeSession
    }
        
    func onAddPressed() {
        let delegate = AddTrainingDelegate(
            onSelectProgram: { [weak self] in
                self?.router.showCreateProgramView(delegate: CreateProgramDelegate())
            },
            onSelectWorkout: { [weak self] in
                self?.router.showCreateWorkoutView(delegate: CreateWorkoutDelegate())
            },
            onSelectExercise: { [weak self] in
                self?.router.showCreateExerciseView()
            }
        )
        router.showAddTrainingView(delegate: delegate, onDismiss: nil)
    }
        
    func onProfilePressed() {
        router.showProfileView()
    }
    
    func getLoggedWorkoutCountForDate(_ date: Date, calendar: Calendar) -> Int {
        // TODO: Implement workout count logic here
        return 0
    }

    // MARK: - Active Workout Safeguard
    
    /// Checks if there's an active workout and shows a confirmation dialog if so.
    /// Returns true if it's safe to proceed, false if the user needs to make a choice.
    private func checkForActiveWorkout(onResumeWorkout: @escaping @Sendable () -> Void, onStartNewWorkout: @escaping @Sendable () -> Void) -> Bool {
        guard let activeSession = activeSession else {
            // No active workout, safe to proceed
            return true
        }
        
        // Show confirmation dialog
        router.showAlert(
            title: "Workout In Progress",
            subtitle: "You already have '\(activeSession.name)' in progress. What would you like to do?",
            buttons: {
                AnyView(
                    VStack {
                        Button("Resume Current Workout") {
                            onResumeWorkout()
                        }
                        Button("Discard & Start New", role: .destructive) {
                            try? self.interactor.deleteActiveSession()
                            onStartNewWorkout()
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                )
            }
        )
        
        return false
    }
    
    func onProgramPressed(program: TrainingProgram) {
        router.showEditTrainingProgramView(delegate: EditTrainingProgramDelegate(program: program))
    }
    
    func onProgramDeletePressed(program: TrainingProgram) {
        router.showAlert(
            title: "Delete Training Program",
            subtitle: "Are you sure you want to delete your active training program? This cannot be undone.",
            buttons: {
                AnyView(
                    VStack {
                        Button(role: .destructive) {
                            Task { try? await self.deleteTrainingProgram(programId: program.id) }
                        }
                        Button(role: .cancel) { }
                    }
                )
            }
        )
    }
    
    private func deleteTrainingProgram(programId: String) async throws {
        try await interactor.deleteTrainingProgram(programId: programId)
    }
    
    private func resumeActiveWorkout() {
        guard let activeSession = activeSession else { return }
        router.showWorkoutTrackerView(delegate: WorkoutTrackerDelegate(workoutSessionId: activeSession.id))
    }

    func startWorkoutTemplateModelWorkout(_ dayPlan: WorkoutTemplateModel) {
        let shouldProceed = checkForActiveWorkout(
            onResumeWorkout: { [weak self] in
                Task {
                    await self?.resumeActiveWorkout()
                }
            },
            onStartNewWorkout: { [weak self] in
                Task {
                    await self?.performStartWorkoutTemplateModelWorkout(dayPlan)
                }
            }
        )
        
        if shouldProceed {
            performStartWorkoutTemplateModelWorkout(dayPlan)
        }
    }
    
    private func performStartWorkoutTemplateModelWorkout(_ dayPlan: WorkoutTemplateModel) {
        interactor.trackEvent(event: Event.startWorkoutRequestedStart)
        do {
            let authId = try interactor.getAuthId()
            let template = WorkoutTemplateModel.newWorkoutTemplate(
                name: dayPlan.name,
                authorId: authId,
                exercises: dayPlan.exercises
            )
                        
            // Notify parent to show WorkoutStartView
            handleWorkoutStartRequest(
                template: template,
                programId: activeTrainingProgram?.id,
                dayPlanId: dayPlan.id
            )
            interactor.trackEvent(event: Event.startWorkoutRequestedSuccess)

        } catch {
            interactor.trackEvent(event: Event.startWorkoutRequestedFail(error: error))
            self.router.showAlert(error: error)
        }
    }
    
    func openCompletedSession(sessionId: String) {
        interactor.trackEvent(event: Event.openCompletedSessionStart)
        guard let session = workoutSessions.first(where: { $0.id == sessionId }) else { return }
        router.showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate(workoutSession: session))
        interactor.trackEvent(event: Event.openCompletedSessionSuccess)
    }

    func onDatePressed(date: Date) {
        self.selectedDate = date.startOfDay
        
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
            
    func onStartEmptyWorkoutPressed() {
        let shouldProceed = checkForActiveWorkout(
            onResumeWorkout: { [weak self] in
                Task { @MainActor in
                    self?.router.dismissScreen()
                    self?.resumeActiveWorkout()
                }
            },
            onStartNewWorkout: { [weak self] in
                Task { @MainActor in
                    self?.performStartEmptyWorkout()
                }
            }
        )
        
        if shouldProceed {
            performStartEmptyWorkout()
        }
    }
    
    private func performStartEmptyWorkout() {
        guard let userId = currentUser?.userId else { return }
        let session = WorkoutSessionModel(
            id: UUID().uuidString,
            authorId: userId,
            name: "Untitled Workout",
            dateCreated: .now,
            exercises: []
        )
        guard (try? interactor.updateActiveSession(session)) != nil else { return }
        defer {
            Task {
                try? await Task.sleep(for: .seconds(0.1))
                await MainActor.run {
                    router.showWorkoutTrackerView(delegate: WorkoutTrackerDelegate(workoutSessionId: session.id))
                }
            }
        }
        router.dismissScreen()
    }
    
    // MARK: - Data Loading
        
    func refreshData() async {
        interactor.trackEvent(event: Event.refreshDataStart)
    }

    func onProgramManagementPressed() {
        router.showProgramManagementView()
    }

    func onChooseProgramPressed() {
        router.showProgramManagementView()
    }
    
    func onWorkoutLibraryPressed() {
        router.showWorkoutsView()
    }
        
    func onWorkoutHistoryPressed() {
        router.showWorkoutHistoryView()
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
        
    enum Event: LoggableEvent {
        case onAppear(delegate: TrainingDelegate)
        case onDisappear(delegate: TrainingDelegate)
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
            case .onAppear:                      return "TrainingView_Appear"
            case .onDisappear:                   return "TrainingView_Disappear"
            case .startWorkoutRequestedStart:    return "TrainingView_StartWorkoutRequested_Start"
            case .startWorkoutRequestedSuccess:  return "TrainingView_StartWorkoutRequested_Success"
            case .startWorkoutRequestedFail:     return "TrainingView_StartWorkoutRequested_Fail"
            case .openCompletedSessionStart:     return "TrainingView_OpenCompletedSession_Start"
            case .openCompletedSessionSuccess:   return "TrainingView_OpenCompletedSession_Success"
            case .openCompletedSessionFail:      return "TrainingView_OpenCompletedSession_Fail"
            case .loadDataStart:                 return "TrainingView_LoadData_Start"
            case .loadDataSuccess:               return "TrainingView_LoadData_Success"
            case .loadDataFail:                  return "TrainingView_LoadData_Fail"
            case .refreshDataStart:              return "TrainingView_RefreshData_Start"
            case .refreshDataSuccess:            return "TrainingView_RefreshData_Success"
            case .refreshDataFail:               return "TrainingView_RefreshData_Fail"
            case .getWeeklyProgress:             return "TrainingView_GetWeeklyProgress"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
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

enum TrainingPresentationMode {
    case program
    case workouts
    case exercises
    case history
}

enum ActiveSheet: Identifiable {
    case programPicker
    case progressAnalytics
    case strengthProgress
    case workoutHeatmap
    case addGoal
    
    var id: String {
        switch self {
        case .programPicker: return "programPicker"
        case .progressAnalytics: return "progressAnalytics"
        case .strengthProgress: return "strengthProgress"
        case .workoutHeatmap: return "workoutHeatmap"
        case .addGoal: return "addGoal"
        }
    }
    
    var eventParameters: [String: Any] {
        let sheet = self
        let params: [String: Any] = [
            "program_sheet": sheet.id
        ]
        
        return params
    }
}

//
//  TrainingPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

struct MicrocycleWorkoutTemplateModelItem: Identifiable {
    let id: String
    let date: Date
    let dayPlan: WorkoutTemplateModel
    let completedSessionId: String?

    var isCompleted: Bool {
        completedSessionId != nil
    }
}

struct MicrocycleCycleState {
    let cycleIndex: Int
    let cyclesTotal: Int
    let completedInCurrentCycle: Set<String>
}

@Observable
@MainActor
class TrainingPresenter {
    
    let interactor: TrainingInteractor
    let router: TrainingRouter
    
    let calendar = Calendar.current
    var selectedDate: Date = Date().startOfDay
    var selectedTime: Date = Date()
    var today: Date = Date().startOfDay
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var userImageUrl: String? {
        interactor.userImageUrl
    }

    var activeSession: WorkoutSessionModel? {
        interactor.activeSession
    }

    var workoutSessions: [WorkoutSessionModel] {
        interactor.workoutSessions
    }

    var activeTrainingProgram: TrainingProgram? {
        interactor.activeTrainingProgram
    }
    
    var favouriteGymProfile: GymProfileModel? {
        interactor.favouriteGymProfile
    }
    
    init(
        interactor: TrainingInteractor,
        router: TrainingRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: TrainingDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: TrainingDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    func onAddPressed() {
        let delegate = AddTrainingDelegate(
            onSelectProgram: { [weak self] in
                self?.router.showCreateProgramView(delegate: CreateProgramDelegate(onDismiss: { self?.router.dismissScreen() }))
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
    
    func onProfilePressed(transitionId: String, namespace: Namespace.ID) {
        router.showProfileViewZoom(transitionId: transitionId, namespace: namespace)
    }
    
    func getLoggedWorkoutCountForDate(_ date: Date, calendar: Calendar) -> Int {
        sessionsForDate(date).count
    }
        
    func onStartEmptyWorkoutPressed() {
        router.showCreateWorkoutView(delegate: CreateWorkoutDelegate(
            onWorkoutCreated: { [weak self] template in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if activeSession != nil {
                        router.showAlert(
                            title: "Active Workout",
                            subtitle: "You already have an active workout.",
                            buttons: {
                                AnyView(VStack {
                                    Button("Resume") { self.router.showWorkoutTrackerView() }
                                    Button("Discard & Start New") {
                                        try? self.interactor.deleteActiveSession()
                                        Task {
                                            try? await self.interactor.startWorkout(for: template, in: nil)
                                            self.router.showWorkoutTrackerView()
                                        }
                                    }
                                    Button("Cancel", role: .cancel) {}
                                })
                            }
                        )
                    } else {
                        do {
                            try await interactor.startWorkout(for: template, in: nil)
                            router.showWorkoutTrackerView()
                        } catch {
                            router.showSimpleAlert(title: "Could Not Start Workout", subtitle: "Please try again.")
                        }
                    }
                }
            }
        ))
    }
    
    func onDatePressed(date: Date) {
        self.selectedDate = date.startOfDay
        let sessions = sessionsForDate(date)
        switch sessions.count {
        case 0:
            break
        case 1:
            openCompletedSession(sessionId: sessions[0].id)
        default:
            showSessionPicker(sessions: sessions)
        }
    }
    
    private func sessionsForDate(_ date: Date) -> [WorkoutSessionModel] {
        interactor.workoutSessions.filter { session in
            guard session.endedAt != nil,
                  calendar.isDate(session.dateCreated, inSameDayAs: date) else { return false }
            if session.isRestDay { return session.dateCreated <= Date() }
            return true
        }
    }
        
    private func resumeActiveWorkout() {
        guard activeSession != nil else { return }
        router.showWorkoutTrackerView()
    }
    
    private func openCompletedSession(sessionId: String) {
        interactor.trackEvent(event: Event.openCompletedSessionStart)
        guard let session = workoutSessions.first(where: { $0.id == sessionId }) else { return }
        router.showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate(workoutSession: session))
        interactor.trackEvent(event: Event.openCompletedSessionSuccess)
    }

    private func showSessionPicker(sessions: [WorkoutSessionModel]) {
        router.showAlert(
            title: "Multiple Workouts",
            subtitle: "Which workout would you like to open?",
            buttons: {
                AnyView(
                    VStack {
                        ForEach(sessions) { session in
                            let time = session.dateCreated.formatted(date: .omitted, time: .shortened)
                            Button("\(session.name) · \(time)") {
                                self.openCompletedSession(sessionId: session.id)
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                )
            }
        )
    }
        
    // MARK: - Library Navigation
    
    func onTrainingProgramLibraryView() {
        router.showTrainingProgramLibraryView()
    }
    
    func onChooseProgramPressed() {
        router.showTrainingProgramLibraryView()
    }
    
    func onWorkoutLibraryPressed() {
        router.showWorkoutsView(delegate: WorkoutsDelegate())
    }
    
    func onWorkoutHistoryPressed() {
        router.showWorkoutHistoryView()
    }
    
    #if DEV || MOCK
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    #endif
}

extension TrainingPresenter {
    enum Event: LoggableEvent {
        case onAppear(delegate: TrainingDelegate)
        case onDisappear(delegate: TrainingDelegate)
        case openCompletedSessionStart
        case openCompletedSessionSuccess
        case openCompletedSessionFail(error: Error)
        case loadDataStart
        case loadDataSuccess
        case loadDataFail(error: Error)
        case getWeeklyProgress

        var eventName: String {
            switch self {
            case .onAppear:                      return "TrainingView_Appear"
            case .onDisappear:                   return "TrainingView_Disappear"
            case .openCompletedSessionStart:     return "TrainingView_OpenCompletedSession_Start"
            case .openCompletedSessionSuccess:   return "TrainingView_OpenCompletedSession_Success"
            case .openCompletedSessionFail:      return "TrainingView_OpenCompletedSession_Fail"
            case .loadDataStart:                 return "TrainingView_LoadData_Start"
            case .loadDataSuccess:               return "TrainingView_LoadData_Success"
            case .loadDataFail:                  return "TrainingView_LoadData_Fail"
            case .getWeeklyProgress:             return "TrainingView_GetWeeklyProgress"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            case .loadDataFail(error: let error), .openCompletedSessionFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadDataFail, .openCompletedSessionFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

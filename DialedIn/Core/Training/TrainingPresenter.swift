//
//  TrainingPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TrainingPresenter {
    
    private let interactor: TrainingInteractor
    private let router: TrainingRouter
    
    let calendar = Calendar.current

    var selectedDate: Date = Date()
    var selectedTime: Date = Date()
    
    var today: Date = Date()
    
    private(set) var scheduledWorkouts: [ScheduledWorkout] = []
    private(set) var workoutsForMenu: [ScheduledWorkout] = []

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
        
        loadScheduledWorkouts()
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }

    private(set) var favouriteGymProfileImageUrl: String?
    
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
    
    private func loadScheduledWorkouts() {
        guard let plan = interactor.currentTrainingPlan else {
            scheduledWorkouts = []
            return
        }
        scheduledWorkouts = plan.weeks.flatMap { $0.scheduledWorkouts }
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

    func onCalendarPressed() {
        router.showCalendarView(delegate: CalendarDelegate(onDateSelected: { date, time in
            self.selectedDate = date
            self.selectedTime = time
        }))
    }

    func onDatePressed(date: Date) {
        self.selectedDate = date.startOfDay
        
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
            self.showWorkoutMenu(workoutsForMenu)
        }
    }
    
    private func showWorkoutMenu(_ workouts: [ScheduledWorkout]) {
        router.showConfirmationDialog(
            title: "Select a Workout",
            subtitle: nil, buttons: {
                AnyView(
                    VStack {
                        ForEach(workouts) { workout in
                            Button {
                                Task {
                                    await self.handleWorkoutSelection(workout)
                                }
                            } label: {
                                if let name = workout.workoutName {
                                    Text("\(name) \(workout.isCompleted ? "✓" : "")")
                                } else {
                                    Text("Workout \(workout.isCompleted ? "✓" : "")")
                                }
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                )
            }
        )
    }
    
    private func workoutsForDate(_ date: Date) -> [ScheduledWorkout] {
        let calendar = Calendar.current
        return scheduledWorkouts.filter { workout in
            guard let scheduledDate = workout.scheduledDate else { return false }
            return calendar.isDate(scheduledDate, inSameDayAs: date)
        }
    }
    
    func handleWorkoutSelection(_ workout: ScheduledWorkout) async {
        if workout.isCompleted {
            openCompletedSession(for: workout)
        } else {
            await startWorkout(workout)
        }
    }
            
    func getWeeklyProgress(weekNumber: Int) -> WeekProgress {
        interactor.trackEvent(event: Event.getWeeklyProgress)
        return interactor.getWeeklyProgress(for: weekNumber)
    }
    
    func getWorkoutsForDay(_ day: Date, calendar: Calendar) -> [ScheduledWorkout] {
        scheduledWorkouts
            .filter { workout in
                guard let scheduled = workout.scheduledDate else { return false }
                return calendar.isDate(scheduled, inSameDayAs: day)
            }
            .sorted { ($0.scheduledDate ?? .distantFuture) < ($1.scheduledDate ?? .distantFuture) }
    }

    func getLoggedWorkoutCountForDate(_ day: Date, calendar: Calendar) -> Int {
        scheduledWorkouts
            .filter { workout in
                guard
                    let scheduled = workout.scheduledDate,
                    calendar.isDate(scheduled, inSameDayAs: day)
                else { return false }
                return workout.completedSessionId != nil
            }
            .count
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
    
    func onStartEmptyWorkoutPressed() {
        guard let userId = currentUser?.userId else {
            return
        }
        defer {
            Task {
                let session = WorkoutSessionModel(
                    id: UUID().uuidString,
                    authorId: userId,
                    name: "Untitled Workout",
                    dateCreated: .now,
                    exercises: []
                )
                try interactor.addLocalWorkoutSession(session: session)
                
                try? await Task.sleep(for: .seconds(0.1))
                
                await MainActor.run {
                    interactor.startActiveSession(session)
                    router.showWorkoutTrackerView(delegate: WorkoutTrackerDelegate(workoutSessionId: session.id))
                }
            }
        }
        
        router.dismissScreen()
    }

    func openCompletedSession(for scheduledWorkout: ScheduledWorkout) {
        guard let sessionId = scheduledWorkout.completedSessionId else { return }
        interactor.trackEvent(event: Event.openCompletedSessionStart)
        do {
            let session = try interactor.getLocalWorkoutSession(id: sessionId)
            interactor.trackEvent(event: Event.openCompletedSessionSuccess)
            router.showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate(workoutSession: session))
        } catch {
            router.showAlert(error: error)
            interactor.trackEvent(event: Event.openCompletedSessionFail(error: error))
        }
    }
    
    // MARK: - Data Loading
    
    func loadData() async {
        interactor.trackEvent(event: Event.loadDataStart)
        defer { loadScheduledWorkouts() }
        do {
            try await interactor.syncFromRemote()
            await refreshFavouriteGymProfileImage()
            interactor.trackEvent(event: Event.loadDataSuccess)
        } catch {
            interactor.trackEvent(event: Event.loadDataFail(error: error))
        }
    }
    
    func refreshData() async {
        interactor.trackEvent(event: Event.refreshDataStart)
        defer { loadScheduledWorkouts() }
        do {
            try await interactor.syncFromRemote()
            await refreshFavouriteGymProfileImage()
            interactor.trackEvent(event: Event.refreshDataSuccess)
        } catch {
            interactor.trackEvent(event: Event.refreshDataFail(error: error))
            router.showAlert(error: error)
        }
    }

    func refreshFavouriteGymProfileImage() async {
        guard let favouriteId = currentUser?.favouriteGymProfileId else {
            favouriteGymProfileImageUrl = nil
            return
        }

        do {
            let localProfile = try interactor.readLocalGymProfile(profileId: favouriteId)
            favouriteGymProfileImageUrl = localProfile.imageUrl
            return
        } catch {
            // Fall back to remote fetch if not cached locally.
        }

        do {
            let remoteProfile = try await interactor.readRemoteGymProfile(profileId: favouriteId)
            favouriteGymProfileImageUrl = remoteProfile.imageUrl
        } catch {
            favouriteGymProfileImageUrl = nil
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

    func startTodaysWorkout() {
        Task {
            do {
                let todaysWorkouts = interactor.getTodaysWorkouts()
                guard let firstIncomplete = todaysWorkouts.first(where: { !$0.isCompleted }) else { return }

                let template = try await interactor.getWorkoutTemplate(id: firstIncomplete.workoutTemplateId)

                // Small delay to ensure any pending presentations complete
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

                // Show WorkoutStartView (preview, notes, etc.)
                handleWorkoutStartRequest(template: template, scheduledWorkout: firstIncomplete)
            } catch {
                router.showAlert(error: error)
            }
        }
    }
    
    func getTodaysWorkouts() -> Bool {
        interactor.getTodaysWorkouts().contains(where: { !$0.isCompleted })
    }
    
    func onStartWorkout(delegate: WorkoutStartDelegate) {
        router.showWorkoutStartView(delegate: delegate)
    }

    func onWorkoutLibraryPressed() {
        router.showWorkoutsView()
    }
    
    func onExerciseLibraryPressed() {
        router.showExercisesView()
    }
    
    func onWorkoutHistoryPressed() {
        router.showWorkoutHistoryView()
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    
    func onNotificationsPressed() {
        router.showNotificationsView()
    }
    
    func onGymProfilesPressed() {
        router.showGymProfilesView()
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

enum TrainingPresentationMode {
    case program
    case workouts
    case exercises
    case history
}

enum ActiveSheet: Identifiable {
    case programPicker
    case progressDashboard
    case strengthProgress
    case workoutHeatmap
    case addGoal
    
    var id: String {
        switch self {
        case .programPicker: return "programPicker"
        case .progressDashboard: return "progressDashboard"
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

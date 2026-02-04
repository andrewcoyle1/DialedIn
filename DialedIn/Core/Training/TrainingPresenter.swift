//
//  TrainingPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

struct MicrocycleItem: Identifiable {
    let id: String
    let dayPlan: DayPlan
    let completedSessionId: String?
    
    var isCompleted: Bool {
        completedSessionId != nil
    }
}

struct MicrocycleDayPlanItem: Identifiable {
    let id: String
    let date: Date
    let dayPlan: DayPlan
    let completedSessionId: String?
    
    var isCompleted: Bool {
        completedSessionId != nil
    }
}

@Observable
@MainActor
class TrainingPresenter {
    
    private let interactor: TrainingInteractor
    private let router: TrainingRouter
    
    let calendar = Calendar.current
    private(set) var microcycleHeaderText: String = "Current Microcycle"

    var activeProgramisExpanded: Bool = true
    var selectedDate: Date = Date()
    var selectedTime: Date = Date()
    
    var today: Date = Date()
    
    private(set) var scheduledWorkouts: [ScheduledWorkout] = []
    private(set) var workoutsForMenu: [ScheduledWorkout] = []
    private(set) var weekProgress: WeekProgress?

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
    
    var activeTrainingProgram: TrainingProgram? {
        interactor.activeTrainingProgram
    }

    var userImageUrl: String? {
        interactor.userImageUrl
    }

    private(set) var favouriteGymProfileImageUrl: String?
    
    var currentTrainingPlan: TrainingPlan? {
        interactor.currentTrainingPlan
    }

    var activeSession: WorkoutSessionModel? {
        interactor.activeSession
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
    
    func microcycleItemsForWeek(weekStart: Date, calendar: Calendar) -> [Date: MicrocycleDayPlanItem] {
        guard let program = activeTrainingProgram, !program.dayPlans.isEmpty else {
            microcycleHeaderText = "Current Microcycle"
            return [:]
        }
        
        let weekDates = (0..<7)
            .compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
            .map { calendar.startOfDay(for: $0) }
        let weekDateSet = Set(weekDates)
        
        let completionWindowStart = interactor.currentTrainingPlan?.startDate ?? program.dateCreated
        let dayPlans = program.dayPlans
        let dayPlanNames = Set(dayPlans.map { $0.name })
        let dayPlanById = Dictionary(uniqueKeysWithValues: dayPlans.map { ($0.id, $0) })
        let workoutDayPlanIds = Set(dayPlans.filter { !$0.exercises.isEmpty }.map { $0.id })
        
        let sessions = (try? interactor.getAllLocalWorkoutSessions()) ?? []
        let completedSessions = sessions
            .compactMap { session -> (WorkoutSessionModel, DayPlan)? in
                guard let endedAt = session.endedAt, endedAt >= completionWindowStart else { return nil }
                let shouldInclude = session.programId == program.id
                    || (session.programId == nil && session.dayPlanId == nil && dayPlanNames.contains(session.name))
                guard shouldInclude else { return nil }
                
                if let dayPlanId = session.dayPlanId, let plan = dayPlanById[dayPlanId] {
                    return (session, plan)
                }
                if let plan = dayPlans.first(where: { $0.name == session.name }) {
                    return (session, plan)
                }
                return nil
            }
            .sorted { ($0.0.endedAt ?? .distantPast) < ($1.0.endedAt ?? .distantPast) }
        
        let cyclesTotal = max(program.numMicrocycles, 1)
        var completedCycles = 0
        var completedInCurrentCycle = Set<String>()
        for (_, dayPlan) in completedSessions {
            guard workoutDayPlanIds.contains(dayPlan.id) else { continue }
            completedInCurrentCycle.insert(dayPlan.id)
            if completedInCurrentCycle == workoutDayPlanIds && !workoutDayPlanIds.isEmpty {
                completedCycles += 1
                completedInCurrentCycle.removeAll()
            }
        }
        let cycleIndex = min(completedCycles + 1, cyclesTotal)
        microcycleHeaderText = "Microcycle \(cycleIndex) of \(cyclesTotal)"
        
        var itemsByDay: [Date: MicrocycleDayPlanItem] = [:]
        
        for (session, dayPlan) in completedSessions {
            guard let endedAt = session.endedAt else { continue }
            let day = calendar.startOfDay(for: endedAt)
            guard weekDateSet.contains(day) else { continue }
            guard itemsByDay[day] == nil else { continue }
            
            itemsByDay[day] = MicrocycleDayPlanItem(
                id: "\(day.timeIntervalSince1970)-\(dayPlan.id)",
                date: day,
                dayPlan: dayPlan,
                completedSessionId: session.id
            )
        }
        
        let startIndex: Int
        if workoutDayPlanIds.isEmpty {
            startIndex = 0
        } else if let firstIncompleteIndex = dayPlans.firstIndex(where: { plan in
            plan.exercises.isEmpty ? false : !completedInCurrentCycle.contains(plan.id)
        }) {
            startIndex = firstIncompleteIndex
        } else {
            startIndex = 0
        }
        var nextIndex = startIndex % dayPlans.count
        for day in weekDates where itemsByDay[day] == nil {
            let dayPlan = dayPlans[nextIndex]
            itemsByDay[day] = MicrocycleDayPlanItem(
                id: "\(day.timeIntervalSince1970)-\(dayPlan.id)",
                date: day,
                dayPlan: dayPlan,
                completedSessionId: nil
            )
            nextIndex = (nextIndex + 1) % dayPlans.count
        }
        
        return itemsByDay
    }

    func currentMicrocycleItems() -> [MicrocycleItem] {
        guard let program = activeTrainingProgram, !program.dayPlans.isEmpty else {
            microcycleHeaderText = "Current Microcycle"
            return []
        }
        
        let completionWindowStart = interactor.currentTrainingPlan?.startDate ?? program.dateCreated
        let dayPlans = program.dayPlans
        let dayPlanNames = Set(dayPlans.map { $0.name })
        let dayPlanById = Dictionary(uniqueKeysWithValues: dayPlans.map { ($0.id, $0) })
        let workoutDayPlanIds = Set(dayPlans.filter { !$0.exercises.isEmpty }.map { $0.id })
        
        let sessions = (try? interactor.getAllLocalWorkoutSessions()) ?? []
        let completedSessions = sessions
            .compactMap { session -> (WorkoutSessionModel, DayPlan)? in
                guard let endedAt = session.endedAt, endedAt >= completionWindowStart else { return nil }
                let shouldInclude = session.programId == program.id
                    || (session.programId == nil && session.dayPlanId == nil && dayPlanNames.contains(session.name))
                guard shouldInclude else { return nil }
                
                if let dayPlanId = session.dayPlanId, let plan = dayPlanById[dayPlanId] {
                    return (session, plan)
                }
                if let plan = dayPlans.first(where: { $0.name == session.name }) {
                    return (session, plan)
                }
                return nil
            }
            .sorted { ($0.0.endedAt ?? .distantPast) < ($1.0.endedAt ?? .distantPast) }
        
        let cyclesTotal = max(program.numMicrocycles, 1)
        var completedCycles = 0
        var completedInCurrentCycle = Set<String>()
        var sessionByPlanId: [String: String] = [:]
        
        for (session, dayPlan) in completedSessions {
            guard workoutDayPlanIds.contains(dayPlan.id) else { continue }
            if !completedInCurrentCycle.contains(dayPlan.id) {
                completedInCurrentCycle.insert(dayPlan.id)
                sessionByPlanId[dayPlan.id] = session.id
            }
            if completedInCurrentCycle == workoutDayPlanIds && !workoutDayPlanIds.isEmpty {
                completedCycles += 1
                completedInCurrentCycle.removeAll()
                sessionByPlanId.removeAll()
            }
        }
        
        let cycleIndex = min(completedCycles + 1, cyclesTotal)
        microcycleHeaderText = "Microcycle \(cycleIndex) of \(cyclesTotal)"
        
        return dayPlans.map { plan in
            MicrocycleItem(
                id: plan.id,
                dayPlan: plan,
                completedSessionId: sessionByPlanId[plan.id]
            )
        }
    }

    func onProfilePressed() {
        router.showProfileView()
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
                            onStartNewWorkout()
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                )
            }
        )
        
        return false
    }
    
    func onProgramDeletePressed(program: TrainingProgram) {
        router.showAlert(
            title: "Delete Training Program",
            subtitle: "Are you sure you want to delete your active training program? This cannot be undone.",
            buttons: {
                AnyView(
                    VStack {
                        Button(role:.destructive) {
                            self.deleteTrainingProgram(program: program)
                        }
                        Button(role: .cancel) { }
                    }
                )
            }
        )
    }
    
    private func deleteTrainingProgram(program: TrainingProgram) {
        Task {
            try? await interactor.deleteTrainingProgram(program: program)
            
        }
    }
    
    private func resumeActiveWorkout() {
        guard let activeSession = activeSession else { return }
        router.showWorkoutTrackerView(delegate: WorkoutTrackerDelegate(workoutSessionId: activeSession.id))
    }

    func startDayPlanWorkout(_ dayPlan: DayPlan) {
        let shouldProceed = checkForActiveWorkout(
            onResumeWorkout: { [weak self] in
                Task {
                    await self?.resumeActiveWorkout()
                }
            },
            onStartNewWorkout: { [weak self] in
                Task {
                    await self?.performStartDayPlanWorkout(dayPlan)
                }
            }
        )
        
        if shouldProceed {
            performStartDayPlanWorkout(dayPlan)
        }
    }
    
    private func performStartDayPlanWorkout(_ dayPlan: DayPlan) {
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
                scheduledWorkout: nil,
                programId: activeTrainingProgram?.id,
                dayPlanId: dayPlan.id
            )
            interactor.trackEvent(event: Event.startWorkoutRequestedSuccess)

        } catch {
            interactor.trackEvent(event: Event.startWorkoutRequestedFail(error: error))
            self.router.showAlert(error: error)
        }
    }
    
    private func handleWorkoutStartRequest(
        template: WorkoutTemplateModel,
        scheduledWorkout: ScheduledWorkout?,
        programId: String? = nil,
        dayPlanId: String? = nil
    ) {
        guard let userId = currentUser?.userId else { return }
        router.showWorkoutStartModal(
            delegate: WorkoutStartDelegate(
                template: template,
                scheduledWorkout: scheduledWorkout,
                programId: programId,
                dayPlanId: dayPlanId,
                onStartWorkoutPressed: {
                    
                    do {
                        
                        // Create workout session from template
                        let session = WorkoutSessionModel(
                            authorId: userId,
                            template: template,
                            notes: nil,
                            scheduledWorkoutId: scheduledWorkout?.id,
                            trainingPlanId: nil,
                            programId: programId,
                            dayPlanId: dayPlanId
                        )
                        
                        // Save locally first (MainActor-isolated)
                        try self.interactor.addLocalWorkoutSession(session: session)
                        
                        self.interactor.startActiveSession(session)
                        defer {
                            Task {
                                try? await Task.sleep(for: .seconds(0.5))
                                self.router.dismissModal()
                            }
                        }
                        self.router.showWorkoutTrackerView(delegate: WorkoutTrackerDelegate(workoutSessionId: session.id))
                    } catch {
                        self.router.showSimpleAlert(title: "Unable to start workout", subtitle: "Please try again.")
                    }
                },
                onCancelPressed: {
                    self.router.dismissModal()
                }
            )
        )
    }
    
    func openCompletedSession(sessionId: String) {
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
            
    func getWeeklyProgress() {
        guard let weekNumber = currentWeek?.weekNumber else { return }
        interactor.trackEvent(event: Event.getWeeklyProgress)
        self.weekProgress =  interactor.getWeeklyProgress(for: weekNumber)
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
    
    func startWorkout(_ scheduledWorkout: ScheduledWorkout) async {
        let shouldProceed = checkForActiveWorkout(
            onResumeWorkout: { [weak self] in
                Task {
                    await self?.resumeActiveWorkout()
                }
            },
            onStartNewWorkout: { [weak self] in
                Task {
                    await self?.performStartWorkout(scheduledWorkout)
                }
            }
        )
        
        if shouldProceed {
            await performStartWorkout(scheduledWorkout)
        }
    }
    
    private func performStartWorkout(_ scheduledWorkout: ScheduledWorkout) async {
        interactor.trackEvent(event: Event.startWorkoutRequestedStart)
        do {
            let template = try await interactor.getWorkoutTemplate(id: scheduledWorkout.workoutTemplateId)
            
            // Delay to ensure calendar zoom transition dismiss animation completes
            // before presenting the workout start sheet
            try? await Task.sleep(for: .seconds(0.4))
            
            // Notify parent to show WorkoutStartView
            handleWorkoutStartRequest(template: template, scheduledWorkout: scheduledWorkout)
            interactor.trackEvent(event: Event.startWorkoutRequestedSuccess)

        } catch {
            interactor.trackEvent(event: Event.startWorkoutRequestedFail(error: error))
            self.router.showAlert(error: error)
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
        let shouldProceed = checkForActiveWorkout(
            onResumeWorkout: { [weak self] in
                Task {
                    await self?.resumeActiveWorkout()
                }
            },
            onStartNewWorkout: { [weak self] in
                Task {
                    await self?.performStartTodaysWorkout()
                }
            }
        )
        
        if shouldProceed {
            performStartTodaysWorkout()
        }
    }
    
    private func performStartTodaysWorkout() {
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

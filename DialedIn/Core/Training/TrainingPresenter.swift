//
//  TrainingPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

struct MicrocycleItem: Identifiable {
    let id: String
    let workoutTemplate: WorkoutTemplateModel
    let completedSessionId: String?
    let trainingProgramId: String
    
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
    var isDeloadCycle: Bool = false
    var periodisationPhase: PeriodisationPhase?

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
        
    func onProfilePressed() {
        router.showProfileView()
    }
    
    func getLoggedWorkoutCountForDate(_ date: Date, calendar: Calendar) -> Int {
        sessionsForDate(date).count
    }

    private func sessionsForDate(_ date: Date) -> [WorkoutSessionModel] {
        interactor.workoutSessions.filter { session in
            guard session.endedAt != nil,
                  calendar.isDate(session.dateCreated, inSameDayAs: date) else { return false }
            if session.isRestDay { return session.dateCreated <= Date() }
            return true
        }
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
                    HStack {
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
        guard activeSession != nil else { return }
        router.showWorkoutTrackerView()
    }

    func startWorkoutTemplateModelWorkout(_ workoutTemplate: WorkoutTemplateModel, in trainingProgram: String?) {
        let shouldProceed = checkForActiveWorkout(
            onResumeWorkout: { [weak self] in
                Task {
                    await self?.resumeActiveWorkout()
                }
            },
            onStartNewWorkout: { [weak self] in
                Task {
                    await self?.performStartWorkoutTemplateModelWorkout(workoutTemplate, in: trainingProgram)
                }
            }
        )
        
        if shouldProceed {
            performStartWorkoutTemplateModelWorkout(workoutTemplate, in: trainingProgram)
        }
    }
    
    private func performStartWorkoutTemplateModelWorkout(_ template: WorkoutTemplateModel, in trainingProgramId: String?) {
        // Notify parent to show WorkoutStartView
        router.showWorkoutTemplateDetailView(
            delegate: WorkoutTemplateDetailDelegate(
                workoutTemplate: template,
                trainingProgramId: trainingProgramId,
                onStartWorkoutPressed: { [weak self] in
                    Task { @MainActor in
                        self?.router.showWorkoutTrackerView()
                    }
                },
                isDeloadCycle: isDeloadCycle,
                periodisationPhase: periodisationPhase
            )
        )
//
//        router.showWorkoutStartModal(
//            delegate: WorkoutStartDelegate(
//                template: template,
//                trainingProgramId: trainingProgramId,
//                onStartWorkoutPressed: { [weak self] in
//                    guard let self else { return }
//                    Task {
//                        do {
//                            try await self.interactor.startWorkout(for: template, in: trainingProgramId)
//                            self.router.dismissModal()
//                            self.router.showWorkoutTrackerView()
//                        } catch {
//                            self.router.showSimpleAlert(title: "Unable to start workout", subtitle: "Please try again.")
//                        }
//                    }
//                },
//                onCancelPressed: {
//                    self.router.dismissModal()
//                }
//            )
//        )
    }
    
    func openCompletedSession(sessionId: String) {
        interactor.trackEvent(event: Event.openCompletedSessionStart)
        guard let session = workoutSessions.first(where: { $0.id == sessionId }) else { return }
        router.showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate(workoutSession: session))
        interactor.trackEvent(event: Event.openCompletedSessionSuccess)
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
                    router.showWorkoutTrackerView()
                }
            }
        }
        router.dismissScreen()
    }
    
    func microcycleItemsForWeek(weekStart: Date, calendar: Calendar) -> [Date: MicrocycleWorkoutTemplateModelItem] {
        guard let program = activeTrainingProgram, !program.workoutTemplates.isEmpty else {
            microcycleHeaderText = "Current Microcycle"
            return [:]
        }
        let dayPlans = program.workoutTemplates
        let workoutWorkoutTemplateModelIds = Set(dayPlans.filter { !$0.exercises.isEmpty }.map { $0.id })
        let completedSessions = microcycleCompletedSessions(program: program, dayPlans: dayPlans)
        let weekDates = (0..<7)
            .compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
            .map { calendar.startOfDay(for: $0) }
        let weekDateSet = Set(weekDates)

        let cycleState = microcycleCycleState(
            program: program,
            completedSessions: completedSessions,
            workoutWorkoutTemplateModelIds: workoutWorkoutTemplateModelIds
        )
        microcycleHeaderText = "Microcycle \(cycleState.cycleIndex) of \(cycleState.cyclesTotal)"

        var itemsByDay = microcycleItemsFromCompleted(
            weekDateSet: weekDateSet,
            completedSessions: completedSessions,
            calendar: calendar
        )
        let startIndex = microcycleStartIndex(
            dayPlans: dayPlans,
            workoutWorkoutTemplateModelIds: workoutWorkoutTemplateModelIds,
            completedInCurrentCycle: cycleState.completedInCurrentCycle
        )
        var nextIndex = startIndex % dayPlans.count
        for day in weekDates where itemsByDay[day] == nil {
            let dayPlan = dayPlans[nextIndex]
            itemsByDay[day] = MicrocycleWorkoutTemplateModelItem(
                id: "\(day.timeIntervalSince1970)-\(dayPlan.id)",
                date: day,
                dayPlan: dayPlan,
                completedSessionId: nil
            )
            nextIndex = (nextIndex + 1) % dayPlans.count
        }
        return itemsByDay
    }

    func microcycleCompletedSessions(
        program: TrainingProgram,
        dayPlans: [WorkoutTemplateModel]
    ) -> [(WorkoutSessionModel, WorkoutTemplateModel)] {
        let dayPlanNames = Set(dayPlans.map { $0.name })
        let dayPlanById = Dictionary(uniqueKeysWithValues: dayPlans.map { ($0.id, $0) })
        return workoutSessions
            .compactMap { session -> (WorkoutSessionModel, WorkoutTemplateModel)? in
                guard session.endedAt != nil else { return nil }
                let shouldInclude = session.trainingProgramId == program.id
                    || (session.trainingProgramId == nil && dayPlanNames.contains(session.name))
                guard shouldInclude else { return nil }
                if let dayPlanId = session.workoutTemplateId, let plan = dayPlanById[dayPlanId] {
                    return (session, plan)
                }
                if let plan = dayPlans.first(where: { $0.name == session.name }) {
                    return (session, plan)
                }
                return nil
            }
            .sorted { ($0.0.endedAt ?? .distantPast) < ($1.0.endedAt ?? .distantPast) }
    }

    func microcycleCycleState(
        program: TrainingProgram,
        completedSessions: [(WorkoutSessionModel, WorkoutTemplateModel)],
        workoutWorkoutTemplateModelIds: Set<String>
    ) -> MicrocycleCycleState {
        let cyclesTotal = max(program.numMicrocycles, 1)
        var completedCycles = 0
        var completedInCurrentCycle = Set<String>()
        for (_, dayPlan) in completedSessions {
            guard workoutWorkoutTemplateModelIds.contains(dayPlan.id) else { continue }
            completedInCurrentCycle.insert(dayPlan.id)
            if completedInCurrentCycle == workoutWorkoutTemplateModelIds && !workoutWorkoutTemplateModelIds.isEmpty {
                completedCycles += 1
                completedInCurrentCycle.removeAll()
            }
        }
        let cycleIndex = (completedCycles % cyclesTotal) + 1
        return MicrocycleCycleState(
            cycleIndex: cycleIndex,
            cyclesTotal: cyclesTotal,
            completedInCurrentCycle: completedInCurrentCycle
        )
    }

    func microcycleItemsFromCompleted(
        weekDateSet: Set<Date>,
        completedSessions: [(WorkoutSessionModel, WorkoutTemplateModel)],
        calendar: Calendar
    ) -> [Date: MicrocycleWorkoutTemplateModelItem] {
        var itemsByDay: [Date: MicrocycleWorkoutTemplateModelItem] = [:]
        for (session, dayPlan) in completedSessions {
            guard let endedAt = session.endedAt else { continue }
            if session.isRestDay, session.dateCreated > Date() { continue }
            let day = calendar.startOfDay(for: endedAt)
            guard weekDateSet.contains(day), itemsByDay[day] == nil else { continue }
            itemsByDay[day] = MicrocycleWorkoutTemplateModelItem(
                id: "\(day.timeIntervalSince1970)-\(dayPlan.id)",
                date: day,
                dayPlan: dayPlan,
                completedSessionId: session.id
            )
        }
        return itemsByDay
    }

    func microcycleStartIndex(
        dayPlans: [WorkoutTemplateModel],
        workoutWorkoutTemplateModelIds: Set<String>,
        completedInCurrentCycle: Set<String>
    ) -> Int {
        if workoutWorkoutTemplateModelIds.isEmpty { return 0 }
        if let first = dayPlans.firstIndex(where: { !$0.exercises.isEmpty && !completedInCurrentCycle.contains($0.id) }) {
            return first
        }
        return 0
    }

    func isCurrentCycleDeload(cycleIndex: Int, program: TrainingProgram) -> Bool {
        switch program.deload {
        case .none:  return false
        case .start: return cycleIndex == 1
        case .end:   return cycleIndex == program.numMicrocycles
        }
    }

    func currentPeriodisationPhase(cycleIndex: Int, program: TrainingProgram) -> PeriodisationPhase? {
        guard program.periodisation else { return nil }
        let number = max(program.numMicrocycles, 1)
        let third = max(number / 3, 1)
        if cycleIndex <= third { return .hypertrophy }
        if cycleIndex <= third * 2 { return .strength }
        return .power
    }

    func currentMicrocycleItems() -> [MicrocycleItem] {
        guard let program = activeTrainingProgram, !program.workoutTemplates.isEmpty else {
            microcycleHeaderText = "Current Microcycle"
            return []
        }

        let dayPlans = program.workoutTemplates
        let dayPlanNames = Set(dayPlans.map { $0.name })
        let dayPlanById = Dictionary(uniqueKeysWithValues: dayPlans.map { ($0.id, $0) })
        let workoutWorkoutTemplateModelIds = Set(dayPlans.filter { !$0.exercises.isEmpty }.map { $0.id })

        let completedSessions = workoutSessions
            .compactMap { session -> (WorkoutSessionModel, WorkoutTemplateModel)? in
                let shouldInclude = session.trainingProgramId == program.id
                    || (session.trainingProgramId == nil && session.workoutTemplateId == nil && dayPlanNames.contains(session.name))
                guard shouldInclude else { return nil }
                if let dayPlanId = session.workoutTemplateId, let plan = dayPlanById[dayPlanId] {
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
            guard workoutWorkoutTemplateModelIds.contains(dayPlan.id) else { continue }
            if !completedInCurrentCycle.contains(dayPlan.id) {
                completedInCurrentCycle.insert(dayPlan.id)
                sessionByPlanId[dayPlan.id] = session.id
            }
            if completedInCurrentCycle == workoutWorkoutTemplateModelIds && !workoutWorkoutTemplateModelIds.isEmpty {
                completedCycles += 1
                completedInCurrentCycle.removeAll()
                sessionByPlanId.removeAll()
            }
        }
        let cycleIndex = (completedCycles % cyclesTotal) + 1
        isDeloadCycle = isCurrentCycleDeload(cycleIndex: cycleIndex, program: program)
        periodisationPhase = currentPeriodisationPhase(cycleIndex: cycleIndex, program: program)
        microcycleHeaderText = "Microcycle \(cycleIndex) of \(cyclesTotal)"

        return dayPlans.map { plan in
            MicrocycleItem(
                id: plan.id,
                workoutTemplate: plan,
                completedSessionId: sessionByPlanId[plan.id],
                trainingProgramId: program.id
            )
        }
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

struct MicrocycleCycleState {
    let cycleIndex: Int
    let cyclesTotal: Int
    let completedInCurrentCycle: Set<String>
}

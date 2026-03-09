import SwiftUI

@Observable
@MainActor
class DashboardPresenter {
    
    private let interactor: DashboardInteractor
    private let router: DashboardRouter
    
    var activityNotifications: [ActivityNotificationModel] {
        interactor.activityNotifications
    }
    
    var feedSessions: [WorkoutSessionModel] {
        let ownCompleted = interactor.workoutSessions.filter { $0.endedAt != nil && !$0.isRestDay }
        let combined = ownCompleted + interactor.followingWorkoutSessions
        return combined.sorted { $0.dateCreated > $1.dateCreated }
    }

    var userImageUrl: String? {
        interactor.userImageUrl
    }

    private var completedTrainingDays: Set<Date> {
        let calendar = Calendar.current
        let now = Date()
        return Set(
            interactor.workoutSessions.compactMap { session -> Date? in
                guard session.endedAt != nil else { return nil }
                if session.isRestDay, session.dateCreated > now { return nil }
                return calendar.startOfDay(for: session.dateCreated)
            }
        )
    }

    var workoutStreakCount: Int {
        let days = completedTrainingDays.sorted()
        guard !days.isEmpty else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // If the user hasn't worked out today, start from yesterday (streak is "at risk" but still alive)
        var day = days.contains(today) ? today : calendar.date(byAdding: .day, value: -1, to: today) ?? today
        var streak = 0
        while days.contains(day) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    var isStreakActive: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return completedTrainingDays.contains(today)
    }

    var isStreakAtRisk: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard !completedTrainingDays.contains(today) else { return false }
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        return completedTrainingDays.contains(yesterday)
    }

    var longestStreak: Int {
        let days = completedTrainingDays.sorted()
        guard !days.isEmpty else { return 0 }
        let calendar = Calendar.current
        var longest = 1, current = 1
        for index in 1..<days.count {
            if calendar.dateComponents([.day], from: days[index - 1], to: days[index]).day == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }

    var totalWorkouts: Int {
        interactor.workoutSessions.filter { $0.endedAt != nil && !$0.isRestDay }.count
    }

    var workoutDaysThisWeek: Set<Date> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekdayIndex = calendar.component(.weekday, from: today) - 1
        let weekStart = calendar.date(byAdding: .day, value: -weekdayIndex, to: today) ?? today
        let weekDays = Set((0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekStart)
        })
        return completedTrainingDays.intersection(weekDays)
    }

    var hasActiveProgram: Bool {
        interactor.activeTrainingProgram != nil
    }

    var todaysWorkoutTemplate: WorkoutTemplateModel? {
        todaysScheduledItem?.dayPlan
    }

    var isTodayRestDay: Bool {
        todaysWorkoutTemplate?.exercises.isEmpty == true
    }

    var isTodayCompleted: Bool {
        todaysScheduledItem?.completedSessionId != nil
    }

    private var todaysScheduledItem: MicrocycleWorkoutTemplateModelItem? {
        guard let program = interactor.activeTrainingProgram,
              !program.workoutTemplates.isEmpty else { return nil }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekdayIndex = calendar.component(.weekday, from: today) - 1
        let weekStart = calendar.date(byAdding: .day, value: -weekdayIndex, to: today) ?? today

        let dayPlans = program.workoutTemplates
        let workoutIds = Set(dayPlans.filter { !$0.exercises.isEmpty }.map { $0.id })
        let dayPlanNames = Set(dayPlans.map { $0.name })
        let dayPlanById = Dictionary(uniqueKeysWithValues: dayPlans.map { ($0.id, $0) })

        let completedSessions: [(WorkoutSessionModel, WorkoutTemplateModel)] = interactor.workoutSessions
            .compactMap { session -> (WorkoutSessionModel, WorkoutTemplateModel)? in
                guard session.endedAt != nil else { return nil }
                let shouldInclude = session.trainingProgramId == program.id
                    || (session.trainingProgramId == nil && dayPlanNames.contains(session.name))
                guard shouldInclude else { return nil }
                if let id = session.workoutTemplateId, let plan = dayPlanById[id] { return (session, plan) }
                if let plan = dayPlans.first(where: { $0.name == session.name }) { return (session, plan) }
                return nil
            }
            .sorted { ($0.0.endedAt ?? .distantPast) < ($1.0.endedAt ?? .distantPast) }

        var completedInCurrentCycle = Set<String>()
        for (_, dayPlan) in completedSessions {
            guard workoutIds.contains(dayPlan.id) else { continue }
            completedInCurrentCycle.insert(dayPlan.id)
            if completedInCurrentCycle == workoutIds { completedInCurrentCycle.removeAll() }
        }

        let startIndex: Int
        if workoutIds.isEmpty {
            startIndex = 0
        } else if let first = dayPlans.firstIndex(where: { !$0.exercises.isEmpty && !completedInCurrentCycle.contains($0.id) }) {
            startIndex = first
        } else {
            startIndex = 0
        }

        let weekDates = (0..<7)
            .compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
            .map { calendar.startOfDay(for: $0) }
        let weekDateSet = Set(weekDates)

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
        return itemsByDay[today]
    }

    func author(for session: WorkoutSessionModel) -> UserModel? {
        if let user = interactor.currentUser, session.authorId == user.userId {
            return user
        }
        return interactor.followingUsers.first { $0.userId == session.authorId }
    }

    func onTodaysWorkoutPressed() {
        guard let template = todaysWorkoutTemplate, !isTodayRestDay else { return }
        let programId = interactor.activeTrainingProgram?.id
        router.showWorkoutTemplateDetailView(
            delegate: WorkoutTemplateDetailDelegate(
                workoutTemplate: template,
                trainingProgramId: programId,
                onStartWorkoutPressed: { [weak self] in
                    Task { @MainActor in
                        self?.router.showWorkoutTrackerView()
                    }
                }
            )
        )
    }

    init(interactor: DashboardInteractor, router: DashboardRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: DashboardDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: DashboardDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    func onProfilePressed() {
        router.showProfileView()
    }

    func onPushNotificationsPressed() {
        router.showNotificationsView()
    }
    
    #if DEV || MOCK
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    #endif

    func loadNotifications() async {
        try? await interactor.fetchActivityNotifications()
    }

}

extension DashboardPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: DashboardDelegate)
        case onDisappear(delegate: DashboardDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "DashboardView_Appear"
            case .onDisappear:              return "DashboardView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
//            default:
//                return nil
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

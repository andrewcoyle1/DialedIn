import SwiftUI

@Observable
@MainActor
class DashboardPresenter {
    
    private let interactor: DashboardInteractor
    private let router: DashboardRouter
    
    private(set) var nutritionTotals: DailyMacroTarget?
    private(set) var nutritionTarget: DailyMacroTarget?

    var activityNotifications: [ActivityNotificationModel] {
        interactor.activityNotifications
    }
    
    /// What the feed shows: finished workouts, newest first, each one attributable to a person.
    ///
    /// The same rule has to apply to both halves. Only the user's own sessions used to be filtered,
    /// so a followed athlete's workout appeared the moment they started it, and the rest days a
    /// program pre-creates for the days ahead were posted to the feed as if they had already
    /// happened. A session with no resolvable author is dropped here rather than in the view, so an
    /// empty feed is recognised as empty instead of drawing a header over nothing.
    ///
    /// A blocked author's sessions are dropped too — blocking unfollows, but the following sync can
    /// still hold their sessions until it next emits.
    var feedSessions: [WorkoutSessionModel] {
        let combined = interactor.workoutSessions + interactor.followingWorkoutSessions
        let reader = interactor.currentUser
        return combined
            .filter { $0.endedAt != nil && !$0.isRestDay && author(for: $0) != nil }
            .filter { !(reader?.hasBlocked($0.authorId) ?? false) }
            .sorted { $0.dateCreated > $1.dateCreated }
    }

    var userImageUrl: String? {
        interactor.userImageUrl
    }

    /// People to follow, shown only under the empty feed. Loaded once per appearance of that
    /// state; a person the reader follows from here drops out of the list.
    private(set) var suggestedUsers: [UserModel] = []

    var visibleSuggestedUsers: [UserModel] {
        let following = Set(interactor.currentUser?.followingIds ?? [])
        return suggestedUsers.filter { !following.contains($0.userId) }
    }

    func isFollowing(userId: String) -> Bool {
        interactor.currentUser?.followingIds?.contains(userId) ?? false
    }

    func loadSuggestedUsers() async {
        guard feedSessions.isEmpty else { return }
        suggestedUsers = (try? await interactor.fetchSuggestedUsers()) ?? []
    }

    /// A push tap about a session, relayed by the tab bar once it has selected this tab. Best
    /// effort: if the session cannot be fetched the user is simply left on the Dashboard.
    func onOpenWorkoutSessionNotificationReceived(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            case .session(let id, let authorId, let openComments)? = DeepLink(pushUserInfo: userInfo)
        else { return }
        Task {
            guard let session = try? await interactor.fetchWorkoutSession(id: id, authorId: authorId) else { return }
            let delegate = WorkoutSessionDetailDelegate(workoutSession: session)
            if openComments {
                router.showWorkoutSessionThread(delegate: delegate)
            } else {
                router.showWorkoutSessionDetailView(delegate: delegate)
            }
        }
    }

    func onSuggestedUserPressed(user: UserModel) {
        router.showSocialProfileView(delegate: SocialProfileDelegate(user: user))
    }

    func onFollowPressed(user: UserModel) {
        interactor.trackEvent(eventName: "DashboardView_SuggestedFollow_Press", parameters: nil, type: .analytic)
        Task {
            do {
                try await interactor.followUser(userId: user.userId)
            } catch {
                router.showSimpleAlert(title: "Unable to follow user", subtitle: "Please try again.")
            }
        }
    }

//    private var completedTrainingDays: Set<Date> {
//        let calendar = Calendar.current
//        let now = Date()
//        return Set(
//            interactor.workoutSessions.compactMap { session -> Date? in
//                guard session.endedAt != nil else { return nil }
//                if session.isRestDay, session.dateCreated > now { return nil }
//                return calendar.startOfDay(for: session.dateCreated)
//            }
//        )
//    }

//    var workoutStreakCount: Int {
//        let days = completedTrainingDays.sorted()
//        guard !days.isEmpty else { return 0 }
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        // If the user hasn't worked out today, start from yesterday (streak is "at risk" but still alive)
//        var day = days.contains(today) ? today : calendar.date(byAdding: .day, value: -1, to: today) ?? today
//        var streak = 0
//        while days.contains(day) {
//            streak += 1
//            guard let prev = calendar.date(byAdding: .day, value: -1, to: day) else { break }
//            day = prev
//        }
//        return streak
//    }
//
//    var isStreakActive: Bool {
//        let today = Calendar.current.startOfDay(for: Date())
//        return completedTrainingDays.contains(today)
//    }
//
//    var isStreakAtRisk: Bool {
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        guard !completedTrainingDays.contains(today) else { return false }
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
//        return completedTrainingDays.contains(yesterday)
//    }
//
//    var longestStreak: Int {
//        let days = completedTrainingDays.sorted()
//        guard !days.isEmpty else { return 0 }
//        let calendar = Calendar.current
//        var longest = 1, current = 1
//        for index in 1..<days.count {
//            if calendar.dateComponents([.day], from: days[index - 1], to: days[index]).day == 1 {
//                current += 1
//                longest = max(longest, current)
//            } else {
//                current = 1
//            }
//        }
//        return longest
//    }
//
//    var totalWorkouts: Int {
//        interactor.workoutSessions.filter { $0.endedAt != nil && !$0.isRestDay }.count
//    }
//
//    var workoutDaysThisWeek: Set<Date> {
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        let weekdayIndex = calendar.component(.weekday, from: today) - 1
//        let weekStart = calendar.date(byAdding: .day, value: -weekdayIndex, to: today) ?? today
//        let weekDays = Set((0..<7).compactMap {
//            calendar.date(byAdding: .day, value: $0, to: weekStart)
//        })
//        return completedTrainingDays.intersection(weekDays)
//    }

    var hasActiveProgram: Bool {
        interactor.activeTrainingProgram != nil
    }

    var todaysWorkoutTemplate: WorkoutTemplateModel? {
        todaysScheduledItem?.dayPlan
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

    init(interactor: DashboardInteractor, router: DashboardRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: DashboardDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
        loadNutrition()
    }
    
    func onViewDisappear(delegate: DashboardDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    /// The empty feed's call to action. People search lives on the Add tab, and only the tab bar can
    /// select a tab, so this asks it to — see `DeepLink.post()`.
    func onFindPeoplePressed() {
        interactor.trackEvent(
            eventName: "DashboardView_FindPeople_Press",
            parameters: nil,
            type: .analytic
        )
        DeepLink.tab(.search).post()
    }

    func onProfilePressed(transitionId: String, namespace: Namespace.ID) {
        router.showProfileViewZoom(transitionId: transitionId, namespace: namespace)
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

    func onLogMealPressed() {
        guard let userId = interactor.currentUser?.userId else { return }
        if let meal = interactor.draftMeal {
            router.showAlert(
                title: "Unable to add new meal",
                subtitle: "You already have an draft meal.",
                buttons: {
                    AnyView(
                        VStack {
                            Button("Continue editing") {
                                self.router.showAddMealView(
                                    delegate: AddMealDelegate(mealLog: meal)
                                )
                            }
                            Button("Delete drafted meal", role: .destructive) {
                                try? self.interactor.deleteDraftMeal()
                                self.router.showAddMealView(
                                    delegate: AddMealDelegate(
                                        mealLog: MealLogModel(
                                            authorId: userId,
                                            dayKey: Date().dayKey,
                                            date: Date(),
                                            items: []
                                        )
                                    )
                                )
                            }
                            Button("Cancel", role: .cancel) { }
                        }
                    )
                }
            )
        } else {
            self.router.showAddMealView(
                delegate: AddMealDelegate(
                    mealLog: MealLogModel(
                        authorId: userId,
                        dayKey: Date().dayKey,
                        date: Date(),
                        items: []
                    )
                )
            )
        }
    }

    private func loadNutrition() {
        let dayKey = Date().dayKey
        nutritionTotals = try? interactor.getDailyTotals(dayKey: dayKey)
        guard let userId = interactor.userId else { return }
        Task {
            nutritionTarget = try? await interactor.getDailyTarget(for: Date(), userId: userId)
        }
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

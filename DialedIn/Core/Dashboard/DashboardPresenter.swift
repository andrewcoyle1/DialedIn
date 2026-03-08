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
        var streak = 0
        var day = today
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
        let weekStart = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        ) ?? Date()
        let weekDays = Set((0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekStart)
        }.map { calendar.startOfDay(for: $0) })
        return completedTrainingDays.intersection(weekDays)
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

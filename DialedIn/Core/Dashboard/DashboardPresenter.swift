import SwiftUI

@Observable
@MainActor
class DashboardPresenter {
    
    private let interactor: DashboardInteractor
    private let router: DashboardRouter
    
    var feedSessions: [WorkoutSessionModel] {
        let ownCompleted = interactor.workoutSessions.filter { $0.endedAt != nil }
        let combined = ownCompleted + interactor.followingWorkoutSessions
        return combined.sorted { $0.dateCreated > $1.dateCreated }
    }

    var userImageUrl: String? {
        interactor.userImageUrl
    }

    var workoutStreakCount: Int {
        interactor.currentStreakData.currentStreak ?? 0
    }

    var isStreakActive: Bool {
        interactor.currentStreakData.isStreakActive
    }

    var isStreakAtRisk: Bool {
        interactor.currentStreakData.isStreakAtRisk
    }

    var longestStreak: Int {
        interactor.currentStreakData.longestStreak ?? 0
    }

    var totalWorkouts: Int {
        interactor.currentStreakData.totalEvents ?? 0
    }

    var workoutDaysThisWeek: Set<Date> {
        Set(interactor.currentStreakData.getCalendarDaysWithEventsThisWeek())
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
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
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

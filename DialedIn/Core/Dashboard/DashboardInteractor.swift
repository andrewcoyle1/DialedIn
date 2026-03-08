import SwiftUI

@MainActor
protocol DashboardInteractor: GlobalInteractor {
    var userImageUrl: String? { get }
    var currentUser: UserModel? { get }
    var workoutSessions: [WorkoutSessionModel] { get }
    var activityNotifications: [ActivityNotificationModel] { get }
    var followingWorkoutSessions: [WorkoutSessionModel] { get }
    var followingUsers: [UserModel] { get }
    func followUser(userId: String) async throws
    func unfollowUser(userId: String) async throws
    func fetchActivityNotifications() async throws
}

extension CoreInteractor: DashboardInteractor { }

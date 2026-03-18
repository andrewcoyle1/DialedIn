import SwiftUI

@MainActor
protocol DashboardInteractor: GlobalInteractor {
    var userId: String? { get }
    var userImageUrl: String? { get }
    var currentUser: UserModel? { get }
    var draftMeal: MealLogModel? { get }
    var workoutSessions: [WorkoutSessionModel] { get }
    var activityNotifications: [ActivityNotificationModel] { get }
    var followingWorkoutSessions: [WorkoutSessionModel] { get }
    var followingUsers: [UserModel] { get }
    var activeTrainingProgram: TrainingProgram? { get }
    func deleteDraftMeal() throws 
    func followUser(userId: String) async throws
    func unfollowUser(userId: String) async throws
    func fetchActivityNotifications() async throws
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget
    func getDailyTarget(for date: Date, userId: String) async throws -> DailyMacroTarget?
}

extension CoreInteractor: DashboardInteractor { }

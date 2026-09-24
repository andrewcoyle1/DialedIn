import SwiftUI

@MainActor
protocol SocialProfileInteractor: ReportInteractor {
    var currentUser: UserModel? { get }
    var followingUsers: [UserModel] { get }
    var workoutSessions: [WorkoutSessionModel] { get }
    var activeTrainingProgram: TrainingProgram? { get }
    func fetchWorkoutSessions(authorId: String, limit: Int) async throws -> [WorkoutSessionModel]
    func fetchFollowers(userId: String) async throws -> [UserModel]
    func followUser(userId: String) async throws
    func unfollowUser(userId: String) async throws
    func blockUser(userId: String) async throws
    func unblockUser(userId: String) async throws
}

extension CoreInteractor: SocialProfileInteractor { }

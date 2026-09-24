import SwiftUI

@MainActor
protocol SocialProfileInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var followingUsers: [UserModel] { get }
    func fetchFollowers(userId: String) async throws -> [UserModel]
    func followUser(userId: String) async throws
    func unfollowUser(userId: String) async throws
}

extension CoreInteractor: SocialProfileInteractor { }

import SwiftUI

@MainActor
protocol SocialProfileInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var followingUsers: [UserModel] { get }
    func fetchFollowers(userId: String) async throws -> [UserModel]
}

extension CoreInteractor: SocialProfileInteractor { }

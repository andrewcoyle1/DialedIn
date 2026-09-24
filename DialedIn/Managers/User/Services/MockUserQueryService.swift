import Foundation

@MainActor
class MockUserQueryService: UserQueryService {
    func fetchFollowers(userId: String) async throws -> [UserModel] { [] }
    func searchUsers(query: String) async throws -> [UserModel] { [] }
    func fetchSuggestedUsers(limit: Int) async throws -> [UserModel] { Array(UserModel.mocks.prefix(limit)) }
}

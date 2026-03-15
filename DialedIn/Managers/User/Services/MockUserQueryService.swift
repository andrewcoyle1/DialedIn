import Foundation

@MainActor
class MockUserQueryService: UserQueryService {
    func fetchFollowers(userId: String) async throws -> [UserModel] { [] }
    func searchUsers(query: String) async throws -> [UserModel] { [] }
}

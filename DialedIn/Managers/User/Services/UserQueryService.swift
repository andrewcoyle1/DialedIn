@MainActor
protocol UserQueryService {
    func fetchFollowers(userId: String) async throws -> [UserModel]
    func searchUsers(query: String) async throws -> [UserModel]
    /// The newest accounts, for a reader who follows nobody yet. Excluding the reader and the
    /// people they already follow is the caller's job.
    func fetchSuggestedUsers(limit: Int) async throws -> [UserModel]
}

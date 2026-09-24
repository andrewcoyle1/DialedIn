import Foundation

@MainActor
class MockUserQueryService: UserQueryService {
    /// Follow requests by target id, standing in for each user's `follow_requests` subcollection.
    /// Seeded with one request to the signed-in mock user so the Notifications screen has one to answer.
    private(set) var followRequests: [String: [FollowRequestModel]] = [
        "mock_user_123": [
            FollowRequestModel(
                requesterId: "user2",
                requesterName: "Bob Martinez",
                requesterImageUrl: "https://picsum.photos/seed/bob/200",
                dateCreated: Date().addingTimeInterval(-1800),
                status: .pending
            )
        ]
    ]

    func fetchFollowers(userId: String) async throws -> [UserModel] { [] }
    func searchUsers(query: String) async throws -> [UserModel] { [] }
    func fetchSuggestedUsers(limit: Int) async throws -> [UserModel] { Array(UserModel.mocks.prefix(limit)) }
    func fetchUsers(userIds: [String]) async throws -> [UserModel] {
        UserModel.mocks.filter { userIds.contains($0.userId) }
    }

    func sendFollowRequest(_ request: FollowRequestModel, targetId: String) async throws {
        followRequests[targetId, default: []].removeAll { $0.requesterId == request.requesterId }
        followRequests[targetId, default: []].append(request)
    }

    func deleteFollowRequest(requesterId: String, targetId: String) async throws {
        followRequests[targetId]?.removeAll { $0.requesterId == requesterId }
    }

    func updateFollowRequestStatus(_ status: FollowRequestModel.Status, requesterId: String, targetId: String) async throws {
        guard let index = followRequests[targetId]?.firstIndex(where: { $0.requesterId == requesterId }) else { return }
        followRequests[targetId]?[index].status = status
    }

    func fetchPendingFollowRequests(userId: String) async throws -> [FollowRequestModel] {
        (followRequests[userId] ?? []).filter { $0.status == .pending }
    }

    func fetchSentFollowRequestTargetIds(requesterId: String) async throws -> [String] {
        followRequests.compactMap { targetId, requests in
            requests.contains { $0.requesterId == requesterId && $0.status == .pending } ? targetId : nil
        }
    }
}

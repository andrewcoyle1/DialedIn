import Foundation
import FirebaseFirestore

struct FirebaseUserQueryService: UserQueryService {

    func fetchFollowers(userId: String) async throws -> [UserModel] {
        try await Firestore.firestore()
            .collection("users")
            .whereField(UserModel.CodingKeys.followingIds.rawValue, arrayContains: userId)
            .limit(to: 200)
            .getAllDocuments()
    }

    func searchUsers(query: String) async throws -> [UserModel] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let capitalizedQuery = trimmed.prefix(1).uppercased() + trimmed.dropFirst()
        let field = UserModel.CodingKeys.submittedFirstName.rawValue

        return try await Firestore.firestore()
            .collection("users")
            .whereField(field, isGreaterThanOrEqualTo: capitalizedQuery)
            .whereField(field, isLessThan: capitalizedQuery + "\u{f8ff}")
            .limit(to: 20)
            .getAllDocuments()
    }

    // ponytail: newest accounts, not the most active — swap for a follower-count order once one is stored
    func fetchSuggestedUsers(limit: Int) async throws -> [UserModel] {
        try await Firestore.firestore()
            .collection("users")
            .order(by: UserModel.CodingKeys.creationDate.rawValue, descending: true)
            .limit(to: limit)
            .getAllDocuments()
    }
}

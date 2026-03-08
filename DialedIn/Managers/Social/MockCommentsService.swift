//
//  MockCommentsService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 08/03/2026.
//

import Foundation

@MainActor
class MockCommentsService: CommentsManagerService {

    private var comments: [WorkoutSessionComment] = []

    init() {
        comments = WorkoutSessionComment.mocks
    }

    func fetchComments(sessionId: String) async throws -> [WorkoutSessionComment] {
        comments.filter { $0.sessionId == sessionId && $0.deletedAt == nil }
    }

    func addComment(_ comment: WorkoutSessionComment) async throws {
        comments.append(comment)
    }

    func deleteComment(id: String) async throws {
        if let index = comments.firstIndex(where: { $0.id == id }) {
            comments[index].deletedAt = Date()
        }
    }
}

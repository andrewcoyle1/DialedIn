//
//  WorkoutSessionComment.swift
//  DialedIn
//
//  Created by Andrew Coyle on 08/03/2026.
//

import Foundation

struct WorkoutSessionComment: Identifiable, Codable, Equatable {
    let id: String
    let sessionId: String
    let sessionAuthorId: String
    let authorId: String
    let authorName: String?
    let authorImageUrl: String?
    let text: String
    let dateCreated: Date
    var deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case sessionAuthorId = "session_author_id"
        case authorId = "author_id"
        case authorName = "author_name"
        case authorImageUrl = "author_image_url"
        case text
        case dateCreated = "date_created"
        case deletedAt = "deleted_at"
    }

    @MainActor
    static var mock: WorkoutSessionComment {
        WorkoutSessionComment(
            id: "comment-1",
            sessionId: "session-1",
            sessionAuthorId: "uid",
            authorId: "uid",
            authorName: "Jane Smith",
            authorImageUrl: nil,
            text: "Great session! 💪",
            dateCreated: Date()
        )
    }

    @MainActor
    static var mocks: [WorkoutSessionComment] {
        [
            WorkoutSessionComment(
                id: "comment-1",
                sessionId: "session-1",
                sessionAuthorId: "uid",
                authorId: "uid",
                authorName: "Jane Smith",
                authorImageUrl: nil,
                text: "Great session! 💪",
                dateCreated: Date().addingTimeInterval(-3600)
            ),
            WorkoutSessionComment(
                id: "comment-2",
                sessionId: "session-1",
                sessionAuthorId: "uid",
                authorId: "uid2",
                authorName: "John Doe",
                authorImageUrl: nil,
                text: "Impressive volume!",
                dateCreated: Date().addingTimeInterval(-1800)
            )
        ]
    }
}

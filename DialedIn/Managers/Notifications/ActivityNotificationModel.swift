//
//  ActivityNotificationModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 08/03/2026.
//

import Foundation

struct ActivityNotificationModel: Identifiable {
    enum ActivityType: String {
        case like
        case comment
        /// Someone started following the user. `sessionId` is empty and `sessionAuthorId` is
        /// the followed user, since there is no session behind it.
        case follow
        /// Someone tagged the user in a comment. `commentText` is that comment.
        case mention
    }

    let id: String
    let type: ActivityType
    let actorId: String
    let actorName: String
    let actorImageUrl: String?
    let sessionId: String
    let sessionAuthorId: String
    let commentText: String?
    let dateCreated: Date
    var isRead: Bool
}

extension ActivityNotificationModel {
    static var mocks: [ActivityNotificationModel] {
        [
            ActivityNotificationModel(
                id: "mock_like_1",
                type: .like,
                actorId: "actor_1",
                actorName: "Jane Smith",
                actorImageUrl: nil,
                sessionId: "session_1",
                sessionAuthorId: "user_1",
                commentText: nil,
                dateCreated: Date().addingTimeInterval(-3600),
                isRead: false
            ),
            ActivityNotificationModel(
                id: "mock_comment_1",
                type: .comment,
                actorId: "actor_2",
                actorName: "John Doe",
                actorImageUrl: nil,
                sessionId: "session_1",
                sessionAuthorId: "user_1",
                commentText: "Great session!",
                dateCreated: Date().addingTimeInterval(-7200),
                isRead: true
            ),
            ActivityNotificationModel(
                id: "mock_follow_1",
                type: .follow,
                actorId: "actor_3",
                actorName: "Sam Lee",
                actorImageUrl: nil,
                sessionId: "",
                sessionAuthorId: "user_1",
                commentText: nil,
                dateCreated: Date().addingTimeInterval(-600),
                isRead: false
            )
        ]
    }
}

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
            )
        ]
    }
}

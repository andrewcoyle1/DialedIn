//
//  ActivityNotificationBannerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 08/03/2026.
//

import SwiftUI

struct ActivityNotificationBannerView: View {

    let notification: ActivityNotificationModel

    private var message: String {
        switch notification.type {
        case .like:
            return "\(notification.actorName) liked your workout"
        case .comment:
            if let text = notification.commentText, !text.isEmpty {
                let preview = text.count > 40 ? String(text.prefix(40)) + "…" : text
                return "\(notification.actorName) commented: \"\(preview)\""
            }
            return "\(notification.actorName) commented on your workout"
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "bell.fill")
                .foregroundStyle(.primary)
                .font(.subheadline)

            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}

#Preview {
    VStack {
        ActivityNotificationBannerView(
            notification: ActivityNotificationModel(
                id: "1",
                type: .like,
                actorId: "a",
                actorName: "Jane Smith",
                actorImageUrl: nil,
                sessionId: "s",
                sessionAuthorId: "u",
                commentText: nil,
                dateCreated: Date(),
                isRead: false
            )
        )
        ActivityNotificationBannerView(
            notification: ActivityNotificationModel(
                id: "2",
                type: .comment,
                actorId: "a",
                actorName: "John Doe",
                actorImageUrl: nil,
                sessionId: "s",
                sessionAuthorId: "u",
                commentText: "Great workout, keep it up!",
                dateCreated: Date(),
                isRead: false
            )
        )
    }
    .padding(.top, 60)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(Color.gray.opacity(0.2))
}

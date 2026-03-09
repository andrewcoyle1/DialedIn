//
//  FirebaseActivityNotificationService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 08/03/2026.
//

import Foundation
import FirebaseFirestore

@MainActor
class FirebaseActivityNotificationService: ActivityNotificationService {

    private var listener: ListenerRegistration?

    private func collection(userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("notifications")
    }

    func fetchNotifications(userId: String) async throws -> [ActivityNotificationModel] {
        let snapshot = try await collection(userId: userId)
            .order(by: "date_created", descending: true)
            .limit(to: 50)
            .getDocuments()
        return snapshot.documents.compactMap { Self.parse(doc: $0) }
    }

    func addNotification(_ notification: ActivityNotificationModel, userId: String) async throws {
        var data: [String: Any] = [
            "type": notification.type.rawValue,
            "actor_id": notification.actorId,
            "actor_name": notification.actorName,
            "session_id": notification.sessionId,
            "session_author_id": notification.sessionAuthorId,
            "date_created": Timestamp(date: notification.dateCreated),
            "is_read": notification.isRead
        ]
        if let actorImageUrl = notification.actorImageUrl {
            data["actor_image_url"] = actorImageUrl
        }
        if let commentText = notification.commentText {
            data["comment_text"] = commentText
        }
        try await collection(userId: userId).document(notification.id).setData(data)
    }

    func deleteNotification(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
    }

    func markAllRead(userId: String) async throws {
        let snapshot = try await collection(userId: userId)
            .whereField("is_read", isEqualTo: false)
            .getDocuments()
        let batch = Firestore.firestore().batch()
        for doc in snapshot.documents {
            batch.updateData(["is_read": true], forDocument: doc.reference)
        }
        try await batch.commit()
    }

    func startListening(userId: String, onNew: @escaping (ActivityNotificationModel) -> Void) {
        let listenFromDate = Date()
        listener = collection(userId: userId)
            .whereField("date_created", isGreaterThan: Timestamp(date: listenFromDate))
            .addSnapshotListener { snapshot, _ in
                snapshot?.documentChanges
                    .filter { $0.type == .added }
                    .compactMap { Self.parse(doc: $0.document) }
                    .forEach { onNew($0) }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    private static func parse(doc: QueryDocumentSnapshot) -> ActivityNotificationModel? {
        let data = doc.data()
        guard
            let typeRaw = data["type"] as? String,
            let type = ActivityNotificationModel.ActivityType(rawValue: typeRaw),
            let actorId = data["actor_id"] as? String,
            let actorName = data["actor_name"] as? String,
            let sessionId = data["session_id"] as? String,
            let sessionAuthorId = data["session_author_id"] as? String,
            let dateCreatedTimestamp = data["date_created"] as? Timestamp
        else { return nil }
        return ActivityNotificationModel(
            id: doc.documentID,
            type: type,
            actorId: actorId,
            actorName: actorName,
            actorImageUrl: data["actor_image_url"] as? String,
            sessionId: sessionId,
            sessionAuthorId: sessionAuthorId,
            commentText: data["comment_text"] as? String,
            dateCreated: dateCreatedTimestamp.dateValue(),
            isRead: data["is_read"] as? Bool ?? false
        )
    }
}

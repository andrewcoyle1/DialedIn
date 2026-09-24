//
//  PrivateUserSettings.swift
//  DialedIn
//

import Foundation

/// `users/{uid}/private/settings`: the fields only the owner may read. The public user document is
/// readable by every signed-in user, so the push token and push opt-outs live here instead. The
/// key names are the contract with `pushRecipientSettings` in `functions/lib.js`.
struct PrivateUserSettings: DataSyncModelProtocol, Equatable {

    static let documentId = "settings"

    /// Not stored: the document id is fixed, so the document holds only the fields below.
    var id: String = PrivateUserSettings.documentId
    var fcmToken: String?
    var socialPushLikes: Bool?
    var socialPushComments: Bool?
    var socialPushFollows: Bool?

    enum CodingKeys: String, CodingKey {
        case fcmToken = "fcm_token"
        case socialPushLikes = "social_push_likes"
        case socialPushComments = "social_push_comments"
        case socialPushFollows = "social_push_follows"
    }

    var eventParameters: [String: Any] {
        ["user_has_fcm_token": (fcmToken?.count ?? 0) > 0]
    }

    /// The field that opts out of pushes for one kind of social activity. Must match
    /// `SOCIAL_PUSH_PREFERENCE_KEYS` in `functions/lib.js`.
    static func socialPushKey(for type: ActivityNotificationModel.ActivityType) -> CodingKeys {
        switch type {
        case .like: return .socialPushLikes
        case .comment: return .socialPushComments
        case .follow: return .socialPushFollows
        }
    }

    private static func keyPath(for type: ActivityNotificationModel.ActivityType) -> WritableKeyPath<Self, Bool?> {
        switch type {
        case .like: \.socialPushLikes
        case .comment: \.socialPushComments
        case .follow: \.socialPushFollows
        }
    }

    /// On unless the user has switched it off.
    func isSocialPushEnabled(for type: ActivityNotificationModel.ActivityType) -> Bool {
        self[keyPath: Self.keyPath(for: type)] ?? true
    }

    func settingSocialPush(_ type: ActivityNotificationModel.ActivityType, isEnabled: Bool) -> Self {
        var copy = self
        copy[keyPath: Self.keyPath(for: type)] = isEnabled
        return copy
    }
}

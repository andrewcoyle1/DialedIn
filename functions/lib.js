import { HttpsError } from "firebase-functions/v2/https";

// Callers must be signed in, so AI spend and writes are attributable to a uid.
export function requireAuth(request) {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Sign in required to call this function.");
    }
    return request.auth.uid;
}

// Strip markdown code fences Gemini sometimes wraps JSON in
export function cleanJson(text) {
    return text.replace(/^```(?:json)?\s*/i, "").replace(/\s*```$/, "").trim();
}

export function normaliseName(name) {
    return name.trim().toLowerCase();
}

// The boolean in users/{uid}/private/settings that opts a recipient out of each social push.
// Absent means on, so profiles written before the setting existed keep getting pushes.
export const SOCIAL_PUSH_PREFERENCE_KEYS = {
    like: "social_push_likes",
    comment: "social_push_comments",
    follow: "social_push_follows",
    nudge: "social_push_nudges",
    mention: "social_push_mentions",
    followAccepted: "social_push_follows",
};

// The token and preferences moved from the public user doc to users/{uid}/private/settings. Each
// field is read from the private doc, else the user doc, so a user whose app has not written the
// private doc yet still gets pushes and keeps their opt-outs.
// ponytail: the user-doc fallback can go once every active install writes the private doc.
export function pushRecipientSettings(privateSettings, userDoc) {
    const keys = ["fcm_token", ...Object.values(SOCIAL_PUSH_PREFERENCE_KEYS)];
    return Object.fromEntries(keys.map((key) => [key, privateSettings?.[key] ?? userDoc?.[key]]));
}

const COMMENT_PREVIEW_LENGTH = 60;

function commentPreview(notification) {
    const text = (notification.comment_text || "").trim();
    return text.length > COMMENT_PREVIEW_LENGTH
        ? `${text.slice(0, COMMENT_PREVIEW_LENGTH - 1)}…`
        : text;
}

// Builds the push for a users/{uid}/notifications doc, or null when it should not be sent:
// no token, an unknown type, or the recipient turned that type off. `data.tab` is what
// DeepLink(pushUserInfo:) reads, so a tap lands on the Dashboard where the bell lives; with
// `session_id` and `session_author_id` as well, the Dashboard then opens that session.
export function buildActivityPush(notification, recipient) {
    const token = recipient?.fcm_token;
    const preferenceKey = SOCIAL_PUSH_PREFERENCE_KEYS[notification?.type];
    if (!token || !preferenceKey || recipient[preferenceKey] === false) return null;

    const actor = notification.actor_name || "Someone";
    let title;
    let body;
    switch (notification.type) {
    case "like":
        title = "New like";
        body = `${actor} liked your workout`;
        break;
    case "comment":
        title = "New comment";
        body = `${actor} commented: ${commentPreview(notification)}`;
        break;
    case "mention":
        title = "Mention";
        body = `${actor} mentioned you: ${commentPreview(notification)}`;
        break;
    case "follow":
        title = "New follower";
        body = `${actor} started following you`;
        break;
    case "nudge":
        title = "Nudge";
        body = `${actor} nudged you to train`;
    case "followAccepted":
        title = "Request accepted";
        body = followAcceptedMessage(actor);
        break;
    }

    return {
        token,
        notification: { title, body },
        apns: { payload: { aps: { badge: 1, sound: "default" } } },
        data: {
            tab: "dashboard",
            type: notification.type,
            session_id: notification.session_id || "",
            session_author_id: notification.session_author_id || "",
            actor_id: notification.actor_id || "",
        },
    };
}

// The ids in `after.blocked_user_ids` that were not in `before.blocked_user_ids`, for the trigger
// that makes a block also end the blocked person's follow. Either side may lack the field.
export function newlyBlockedIds(before, after) {
    const previous = new Set(before?.blocked_user_ids ?? []);
    return [...new Set(after?.blocked_user_ids ?? [])].filter((id) => !previous.has(id));
}

// ---------------------------------------------------------------------------
// Follow requests: users/{targetId}/follow_requests/{requesterId}
// ---------------------------------------------------------------------------

export function followAcceptedMessage(name) {
    return `${name || "Someone"} accepted your follow request`;
}

// The name the app shows for a user doc, mirroring UserModel.fullNameCalculated: the submitted
// name where there is one, else the one from auth.
export function userDisplayName(user) {
    const first = user?.submitted_first_name ?? user?.first_name;
    const last = user?.submitted_last_name ?? user?.last_name;
    return [first, last].filter(Boolean).join(" ") || "Someone";
}

// Decides whether an update to a follow request is an acceptance to act on. Returns null unless the
// status has just become "accepted" on a request whose requester_id matches its document id (the id
// the rules pin to the requester's uid); otherwise the ids the trigger needs.
export function planFollowAccepted(before, after, params) {
    if (!after || after.status !== "accepted" || before?.status === "accepted") return null;
    const { targetId, requesterId } = params ?? {};
    if (!targetId || !requesterId || after.requester_id !== requesterId || targetId === requesterId) return null;
    return { requesterId, targetId, notificationId: `follow_accepted_${targetId}` };
}

// The users/{requesterId}/notifications doc telling the requester they were accepted, in the shape
// the app's FirebaseActivityNotificationService parses. The accepting user is the actor.
export function buildFollowAcceptedNotification(target, { targetId, requesterId }, now = new Date()) {
    const notification = {
        type: "followAccepted",
        actor_id: targetId,
        actor_name: userDisplayName(target),
        session_id: "",
        session_author_id: requesterId,
        date_created: now,
        is_read: false,
    };
    const image = target?.submitted_profile_image ?? target?.photo_url;
    if (image) notification.actor_image_url = image;
    return notification;
}

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

// The user-doc boolean that opts a recipient out of each social push. Absent means on, so
// profiles written before the setting existed keep getting pushes.
export const SOCIAL_PUSH_PREFERENCE_KEYS = {
    like: "social_push_likes",
    comment: "social_push_comments",
    follow: "social_push_follows",
};

const COMMENT_PREVIEW_LENGTH = 60;

// Builds the push for a users/{uid}/notifications doc, or null when it should not be sent:
// no token, an unknown type, or the recipient turned that type off. `data.tab` is what
// DeepLink(pushUserInfo:) reads, so a tap lands on the Dashboard where the bell lives.
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
    case "comment": {
        const text = (notification.comment_text || "").trim();
        const preview = text.length > COMMENT_PREVIEW_LENGTH
            ? `${text.slice(0, COMMENT_PREVIEW_LENGTH - 1)}…`
            : text;
        title = "New comment";
        body = `${actor} commented: ${preview}`;
        break;
    }
    case "follow":
        title = "New follower";
        body = `${actor} started following you`;
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
            actor_id: notification.actor_id || "",
        },
    };
}

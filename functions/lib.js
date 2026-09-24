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
        break;
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

// ---------------------------------------------------------------------------
// Scheduled pushes: streak reminder, Sunday digest, and the nudge cooldown
// ---------------------------------------------------------------------------

// Opt-outs for the scheduled pushes, in users/{uid}/private/settings. Absent means on.
export const SCHEDULED_PUSH_PREFERENCE_KEYS = {
    streakReminder: "social_push_streak_reminder",
    weeklyDigest: "social_push_weekly_digest",
};

// The local hour the streak reminder goes out when the user has not picked one. Must match
// PrivateUserSettings.defaultReminderHour in the app.
export const DEFAULT_REMINDER_HOUR = 19;
export const DIGEST_WEEKDAY = 0; // Sunday
export const DIGEST_HOUR = 18;
const DAY_MS = 24 * 60 * 60 * 1000;
const WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

// A Firestore Timestamp, a Date, or nothing, as a Date or null.
export function toDate(value) {
    if (value instanceof Date) return value;
    return typeof value?.toDate === "function" ? value.toDate() : null;
}

// The wall-clock date ("YYYY-MM-DD"), hour (0-23) and weekday (0 = Sunday) of `date` in an IANA
// time zone, or null when the zone is missing or unknown. Intl carries the DST rules, so the hour
// is the one on the user's clock whichever side of a change they are on.
export function localTime(date, timeZone) {
    if (!timeZone || !date) return null;
    let parts;
    try {
        parts = new Intl.DateTimeFormat("en-US", {
            timeZone, hourCycle: "h23", year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", weekday: "short",
        }).formatToParts(date);
    } catch {
        return null;
    }
    const part = (type) => parts.find((p) => p.type === type).value;
    return {
        date: `${part("year")}-${part("month")}-${part("day")}`,
        hour: Number(part("hour")),
        weekday: WEEKDAYS.indexOf(part("weekday")),
    };
}

function previousDay(isoDate) {
    const [y, m, d] = isoDate.split("-").map(Number);
    return new Date(Date.UTC(y, m - 1, d - 1)).toISOString().slice(0, 10);
}

function scheduledPushBase(settings, preferenceKey, now) {
    if (!settings?.fcm_token || settings[preferenceKey] === false) return null;
    return localTime(now, settings.timezone);
}

// Whether it is this user's reminder hour on their clock and they want the reminder. The
// scheduled function checks this before reading the user's streak.
export function isStreakReminderDue(settings, now) {
    const local = scheduledPushBase(settings, SCHEDULED_PUSH_PREFERENCE_KEYS.streakReminder, now);
    return !!local && local.hour === (settings.reminder_hour ?? DEFAULT_REMINDER_HOUR);
}

// The "streak ends at midnight" push for one user, or null. `streak` is the StreakManager doc at
// user_streaks/{uid}/workout/current_streak. Sent in the user's reminder hour when the streak's
// last workout was yesterday on their clock: today means they have trained, earlier means the
// streak has already gone.
// ponytail: ignores the app's 2 leeway hours, so a workout just after midnight counts as today here.
export function buildStreakReminderPush(settings, streak, now) {
    if (!isStreakReminderDue(settings, now)) return null;
    const local = localTime(now, settings.timezone);
    const days = streak?.current_streak ?? 0;
    const lastEvent = localTime(toDate(streak?.date_last_event), settings.timezone);
    if (days <= 0 || !lastEvent || lastEvent.date !== previousDay(local.date)) return null;

    return {
        token: settings.fcm_token,
        notification: { title: "Streak at risk", body: `Your ${days}-day streak ends at midnight` },
        apns: { payload: { aps: { sound: "default" } } },
        data: { tab: "training", type: "streakReminder" },
    };
}

// Whether it is 18:00 on Sunday on this user's clock and they want the digest. The scheduled
// function checks this before reading anything else about the user.
export function isWeeklyDigestDue(settings, now) {
    const local = scheduledPushBase(settings, SCHEDULED_PUSH_PREFERENCE_KEYS.weeklyDigest, now);
    return !!local && local.weekday === DIGEST_WEEKDAY && local.hour === DIGEST_HOUR;
}

// The start of the digest's week: the seven days up to now.
export function digestWindowStart(now) {
    return new Date(now.getTime() - 7 * DAY_MS);
}

// Sessions that count as training: not deleted and not a logged rest day.
export function countTrainingSessions(sessions) {
    return (sessions ?? []).filter((s) => !s.deleted_at && !s.is_rest_day).length;
}

// The Sunday digest, or null when there is no token or the user follows nobody.
export function buildWeeklyDigestPush(settings, { mine, circle, followingCount }) {
    if (!settings?.fcm_token || !followingCount) return null;
    return {
        token: settings.fcm_token,
        notification: {
            title: "Your week",
            body: `This week: you trained ${mine} ${mine === 1 ? "time" : "times"}, your circle ${circle}`,
        },
        apns: { payload: { aps: { sound: "default" } } },
        data: { tab: "dashboard", type: "weeklyDigest" },
    };
}

// True when `previous` (the last nudge from the same actor to the same recipient) was under 24
// hours before `now`. The app writes one nudge doc per actor per day, so this is what stops a
// nudge at 23:59 and another at 00:01 both pushing.
export function isNudgeOnCooldown(previous, now) {
    const last = toDate(previous);
    if (!last) return false;
    const elapsed = toDate(now).getTime() - last.getTime();
    return elapsed < DAY_MS;
}

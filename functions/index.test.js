import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import {
    buildActivityPush, buildFollowAcceptedNotification, cleanJson, followAcceptedMessage, newlyBlockedIds, normaliseName,
    planFollowAccepted, pushRecipientSettings, requireAuth, userDisplayName,
    buildFollowRequestPush, removedFollowingIds, planAutoAccept, removeFollowerTarget,
    buildStreakReminderPush, buildWeeklyDigestPush, countTrainingSessions, digestWindowStart, isNudgeOnCooldown,
    isStreakReminderDue, isWeeklyDigestDue, localTime,
} from "./lib.js";

test("cleanJson strips the code fences Gemini adds and leaves bare JSON alone", () => {
    assert.equal(cleanJson('```json\n{"a":1}\n```'), '{"a":1}');
    assert.equal(cleanJson('```\n{"a":1}```'), '{"a":1}');
    assert.equal(cleanJson('  {"a":1}  '), '{"a":1}');
});

test("normaliseName folds case and whitespace so the same ingredient is found again", () => {
    assert.equal(normaliseName("  Greek Yoghurt "), "greek yoghurt");
});

test("requireAuth returns the uid or throws unauthenticated", () => {
    assert.equal(requireAuth({ auth: { uid: "u1" } }), "u1");
    assert.throws(() => requireAuth({ auth: null }), { code: "unauthenticated" });
    assert.throws(() => requireAuth({}), { code: "unauthenticated" });
});

// The only thing stopping a rebuilt client from calling the backend is App Check plus auth on
// every callable, and enforceAppCheck lives in options the deployed object does not expose, so
// this reads the source: each onCall must take CALLABLE_OPTIONS and open with requireAuth.
test("every callable enforces App Check and requires auth", () => {
    const src = readFileSync(new URL("./index.js", import.meta.url), "utf8");
    assert.match(src, /const CALLABLE_OPTIONS = \{[^}]*enforceAppCheck: true/);
    const callables = [...src.matchAll(/export const (\w+) = onCall\(([^,]+),\s*async \(request\) => \{\s*([^\n]*)/g)];
    assert.equal(callables.length, 7, "expected seven callables");
    for (const [, name, options, firstLine] of callables) {
        assert.equal(options.trim(), "CALLABLE_OPTIONS", `${name} must use CALLABLE_OPTIONS`);
        assert.match(firstLine, /requireAuth\(request\)/, `${name} must call requireAuth first`);
    }
});

test("each deployed callable rejects an unauthenticated request before doing any work", async () => {
    const fns = await import("./index.js");
    for (const name of ["foodAnalyze", "mealDescribe", "nutritionLabelAnalyze", "chatGenerate", "imageGenerate", "foodSearch", "removeFollower"]) {
        await assert.rejects(fns[name].run({ data: {}, auth: null }), { code: "unauthenticated" }, name);
    }
});

test("buildActivityPush titles each social type and routes the tap to the Dashboard tab", () => {
    const recipient = { fcm_token: "tok" };
    const like = buildActivityPush({ type: "like", actor_name: "Jane", session_id: "s1", session_author_id: "u1", actor_id: "a1" }, recipient);
    assert.equal(like.token, "tok");
    assert.deepEqual(like.notification, { title: "New like", body: "Jane liked your workout" });
    assert.deepEqual(like.data, { tab: "dashboard", type: "like", session_id: "s1", session_author_id: "u1", actor_id: "a1" });

    const comment = buildActivityPush({ type: "comment", actor_name: "Jane", comment_text: "Nice!" }, recipient);
    assert.deepEqual(comment.notification, { title: "New comment", body: "Jane commented: Nice!" });

    const follow = buildActivityPush({ type: "follow", actor_name: "Jane" }, recipient);
    assert.deepEqual(follow.notification, { title: "New follower", body: "Jane started following you" });
    assert.equal(follow.data.session_id, "");
    assert.equal(follow.data.session_author_id, "");

    assert.equal(buildActivityPush({ type: "like" }, recipient).notification.body, "Someone liked your workout");
});

test("buildActivityPush tells a mentioned user who tagged them, with the comment's preview", () => {
    const mention = buildActivityPush(
        { type: "mention", actor_name: "Jane", comment_text: " Nice one @Sam ", session_id: "s1", session_author_id: "u1" },
        { fcm_token: "tok" }
    );
    assert.deepEqual(mention.notification, { title: "Mention", body: "Jane mentioned you: Nice one @Sam" });
    assert.equal(mention.data.type, "mention");
    assert.equal(mention.data.session_id, "s1");
    assert.equal(mention.data.session_author_id, "u1");
    const long = buildActivityPush({ type: "mention", actor_name: "Jane", comment_text: "z".repeat(100) }, { fcm_token: "tok" });
    assert.equal(long.notification.body, `Jane mentioned you: ${"z".repeat(59)}…`);
});

test("buildActivityPush truncates a long comment to a 60-character preview", () => {
    const long = "x".repeat(100);
    const { body } = buildActivityPush({ type: "comment", actor_name: "Jane", comment_text: long }, { fcm_token: "tok" }).notification;
    assert.equal(body, `Jane commented: ${"x".repeat(59)}…`);
    const exact = buildActivityPush({ type: "comment", actor_name: "Jane", comment_text: "y".repeat(60) }, { fcm_token: "tok" });
    assert.equal(exact.notification.body, `Jane commented: ${"y".repeat(60)}`);
});

test("buildActivityPush sends nothing without a token, for an unknown type, or when opted out", () => {
    assert.equal(buildActivityPush({ type: "like" }, {}), null);
    assert.equal(buildActivityPush({ type: "like" }, undefined), null);
    assert.equal(buildActivityPush({ type: "poke" }, { fcm_token: "tok" }), null);
    assert.equal(buildActivityPush({ type: "mention" }, { fcm_token: "tok", social_push_mentions: false }), null);
    assert.equal(buildActivityPush({ type: "like" }, { fcm_token: "tok", social_push_likes: false }), null);
    assert.equal(buildActivityPush({ type: "comment" }, { fcm_token: "tok", social_push_comments: false }), null);
    assert.equal(buildActivityPush({ type: "follow" }, { fcm_token: "tok", social_push_follows: false }), null);
    assert.equal(buildActivityPush({ type: "nudge" }, { fcm_token: "tok", social_push_nudges: false }), null);
    // Opting out of one type leaves the others on.
    assert.notEqual(buildActivityPush({ type: "follow" }, { fcm_token: "tok", social_push_likes: false }), null);
});

test("newlyBlockedIds returns only the ids the update added to blocked_user_ids", () => {
    assert.deepEqual(newlyBlockedIds({ blocked_user_ids: ["a"] }, { blocked_user_ids: ["a", "b"] }), ["b"]);
    // Profiles written before blocking existed have no field on either side.
    assert.deepEqual(newlyBlockedIds({}, { blocked_user_ids: ["a"] }), ["a"]);
    assert.deepEqual(newlyBlockedIds(undefined, undefined), []);
    assert.deepEqual(newlyBlockedIds({ blocked_user_ids: ["a"] }, {}), []);
    // An unblock, or an update that leaves the list alone, has nothing to clean up.
    assert.deepEqual(newlyBlockedIds({ blocked_user_ids: ["a", "b"] }, { blocked_user_ids: ["a"] }), []);
    assert.deepEqual(newlyBlockedIds({ blocked_user_ids: ["a"] }, { blocked_user_ids: ["a"], is_private: true }), []);
    assert.deepEqual(newlyBlockedIds({}, { blocked_user_ids: ["a", "a"] }), ["a"]);
});

test("pushRecipientSettings reads the private doc first and falls back to the user doc", () => {
    const legacy = { fcm_token: "old", social_push_likes: false, social_push_comments: false, display_name: "x" };

    // Not migrated yet: everything comes from the user doc, and nothing else is copied over.
    assert.deepEqual(pushRecipientSettings(undefined, legacy), {
        fcm_token: "old", social_push_likes: false, social_push_comments: false, social_push_follows: undefined,
        social_push_nudges: undefined, social_push_mentions: undefined, social_push_shares: undefined,
    });

    // Migrated: the private doc wins field by field, including a false over a legacy true.
    const merged = pushRecipientSettings({ fcm_token: "new", social_push_comments: true, social_push_follows: false }, legacy);
    assert.equal(merged.fcm_token, "new");
    assert.equal(merged.social_push_likes, false);
    assert.equal(merged.social_push_comments, true);
    assert.equal(merged.social_push_follows, false);
    assert.equal(pushRecipientSettings({ social_push_likes: false }, { social_push_likes: true }).social_push_likes, false);

    // Neither doc: no token, so buildActivityPush sends nothing.
    assert.equal(buildActivityPush({ type: "like" }, pushRecipientSettings(undefined, undefined)), null);
    assert.equal(buildActivityPush({ type: "like" }, pushRecipientSettings({ fcm_token: "new" }, undefined)).token, "new");
});

test("buildActivityPush turns a nudge into a push with no session behind it", () => {
    const nudge = buildActivityPush({ type: "nudge", actor_name: "Jane", actor_id: "a1" }, { fcm_token: "tok" });
    assert.deepEqual(nudge.notification, { title: "Nudge", body: "Jane nudged you to train" });
    assert.deepEqual(nudge.data, { tab: "dashboard", type: "nudge", session_id: "", session_author_id: "", actor_id: "a1" });
});

test("planFollowAccepted acts only when a request has just become accepted", () => {
    const params = { targetId: "t1", requesterId: "r1" };
    const pending = { requester_id: "r1", status: "pending" };
    const accepted = { requester_id: "r1", status: "accepted" };

    assert.deepEqual(planFollowAccepted(pending, accepted, params), {
        requesterId: "r1", targetId: "t1", notificationId: "follow_accepted_t1",
    });
    assert.equal(planFollowAccepted(pending, { ...pending, status: "declined" }, params), null);
    assert.equal(planFollowAccepted(pending, pending, params), null);
    // Already accepted before this write: the follow was handled then.
    assert.equal(planFollowAccepted(accepted, accepted, params), null);
    // Deleted, or a request whose body names someone other than its document id.
    assert.equal(planFollowAccepted(pending, undefined, params), null);
    assert.equal(planFollowAccepted(pending, { requester_id: "intruder", status: "accepted" }, params), null);
    assert.equal(planFollowAccepted(pending, accepted, { targetId: "r1", requesterId: "r1" }), null);
    assert.equal(planFollowAccepted(pending, accepted, {}), null);
});

test("buildFollowAcceptedNotification names the accepting user in the shape the app parses", () => {
    const now = new Date(0);
    const plan = { targetId: "t1", requesterId: "r1" };
    const doc = buildFollowAcceptedNotification(
        { submitted_first_name: "Jane", last_name: "Smith", photo_url: "https://img" }, plan, now
    );
    assert.deepEqual(doc, {
        type: "followAccepted",
        actor_id: "t1",
        actor_name: "Jane Smith",
        actor_image_url: "https://img",
        session_id: "",
        session_author_id: "r1",
        date_created: now,
        is_read: false,
    });
    assert.equal(buildFollowAcceptedNotification(undefined, plan, now).actor_name, "Someone");
    assert.equal("actor_image_url" in buildFollowAcceptedNotification({}, plan, now), false);
});

test("userDisplayName prefers the submitted name and falls back to Someone", () => {
    assert.equal(userDisplayName({ submitted_first_name: "Sam", first_name: "Samuel" }), "Sam");
    assert.equal(userDisplayName({ first_name: "Al", last_name: "Bo" }), "Al Bo");
    assert.equal(userDisplayName({}), "Someone");
    assert.equal(followAcceptedMessage("Jane"), "Jane accepted your follow request");
});

test("buildActivityPush sends a followAccepted push under the follows preference", () => {
    const push = buildActivityPush({ type: "followAccepted", actor_name: "Jane", actor_id: "t1" }, { fcm_token: "tok" });
    assert.deepEqual(push.notification, { title: "Request accepted", body: "Jane accepted your follow request" });
    assert.equal(buildActivityPush({ type: "followAccepted" }, { fcm_token: "tok", social_push_follows: false }), null);
});

test("buildFollowRequestPush asks the target, routes to notifications and respects the follows opt-out", () => {
    const request = { requester_id: "r1", requester_name: "Jane", status: "pending" };
    const push = buildFollowRequestPush(request, { fcm_token: "tok" }, {});
    assert.equal(push.token, "tok");
    assert.deepEqual(push.notification, { title: "Follow request", body: "Jane wants to follow you" });
    assert.deepEqual(push.data, { tab: "dashboard", type: "follow_request", session_id: "", session_author_id: "", actor_id: "r1" });
    assert.equal(buildFollowRequestPush({ ...request, requester_name: undefined }, { fcm_token: "tok" }).notification.body, "Someone wants to follow you");

    assert.equal(buildFollowRequestPush(request, { fcm_token: "tok", social_push_follows: false }, {}), null);
    assert.equal(buildFollowRequestPush(request, {}, {}), null);
    assert.equal(buildFollowRequestPush({ ...request, status: "accepted" }, { fcm_token: "tok" }, {}), null);
    assert.equal(buildFollowRequestPush(request, { fcm_token: "tok" }, { blocked_user_ids: ["r1"] }), null);
    assert.equal(buildFollowRequestPush(undefined, { fcm_token: "tok" }, {}), null);
});

test("removedFollowingIds returns only the ids an update dropped from following_ids", () => {
    assert.deepEqual(removedFollowingIds({ following_ids: ["a", "b"] }, { following_ids: ["a"] }), ["b"]);
    assert.deepEqual(removedFollowingIds({ following_ids: ["a"] }, {}), ["a"]);
    assert.deepEqual(removedFollowingIds({}, { following_ids: ["a"] }), []);
    assert.deepEqual(removedFollowingIds(undefined, undefined), []);
    assert.deepEqual(removedFollowingIds({ following_ids: ["a"] }, { following_ids: ["a"], is_private: true }), []);
});

test("planAutoAccept accepts every valid pending request only when a profile goes public", () => {
    const requests = [
        { id: "r1", data: { requester_id: "r1", status: "pending" } },
        { id: "r2", data: { requester_id: "r2", status: "declined" } },
        { id: "r3", data: { requester_id: "intruder", status: "pending" } },
        { id: "r4", data: { requester_id: "r4", status: "pending" } },
    ];
    assert.deepEqual(planAutoAccept({ is_private: true }, { is_private: false }, requests), ["r1", "r4"]);
    assert.deepEqual(planAutoAccept({ is_private: true }, { is_private: false }, []), []);
    assert.equal(planAutoAccept({ is_private: false }, { is_private: true }, requests), null);
    assert.equal(planAutoAccept({ is_private: true }, { is_private: true }, requests), null);
    assert.equal(planAutoAccept({}, { is_private: false }, requests), null);
    assert.equal(planAutoAccept(undefined, undefined, requests), null);
});

test("removeFollowerTarget takes a follower id that is not the caller", () => {
    assert.equal(removeFollowerTarget({ followerId: "f1" }, "me"), "f1");
    assert.equal(removeFollowerTarget({ followerId: "me" }, "me"), null);
    assert.equal(removeFollowerTarget({ followerId: " " }, "me"), null);
    assert.equal(removeFollowerTarget({ followerId: 3 }, "me"), null);
    assert.equal(removeFollowerTarget({}, "me"), null);
    assert.equal(removeFollowerTarget(undefined, "me"), null);
});

// ---------------------------------------------------------------------------
// Usernames
// ---------------------------------------------------------------------------

import { planUsernameRelease, shouldReleaseReservation } from "./lib.js";

test("planUsernameRelease releases the old handle only when it changed or the user was deleted", () => {
    assert.equal(planUsernameRelease({ username: "bob" }, { username: "bobby" }), "bob");
    assert.equal(planUsernameRelease({ username: "bob" }, {}), "bob");
    assert.equal(planUsernameRelease({ username: "bob" }, undefined), "bob");
    assert.equal(planUsernameRelease({ username: "bob" }, { username: "bob" }), null);
    assert.equal(planUsernameRelease({}, { username: "bob" }), null);
    assert.equal(planUsernameRelease(undefined, { username: "bob" }), null);
    assert.equal(planUsernameRelease({ username: "" }, {}), null);
});

test("shouldReleaseReservation leaves a handle someone else now holds", () => {
    assert.equal(shouldReleaseReservation({ user_id: "u1" }, "u1"), true);
    assert.equal(shouldReleaseReservation({ user_id: "u2" }, "u1"), false);
    assert.equal(shouldReleaseReservation(undefined, "u1"), false);
    assert.equal(shouldReleaseReservation({ user_id: undefined }, undefined), false);
});

test("buildActivityPush sends a share push under the shares preference", () => {
    const push = buildActivityPush({ type: "share", actor_name: "Jane" }, { fcm_token: "tok" });
    assert.deepEqual(push.notification, { title: "Shared with you", body: "Jane shared a workout with you" });
    assert.equal(buildActivityPush({ type: "share" }, { fcm_token: "tok", social_push_shares: false }), null);
});

// ---------------------------------------------------------------------------
// Scheduled pushes
// ---------------------------------------------------------------------------

test("localTime reads the user's wall clock across time zones and DST, and rejects bad zones", () => {
    const instant = new Date("2026-03-08T12:30:00Z");
    assert.deepEqual(localTime(instant, "Europe/London"), { date: "2026-03-08", hour: 12, weekday: 0 });
    // US clocks sprang forward at 02:00 that morning: 12:30Z is 08:30 EDT, not 07:30 EST.
    assert.deepEqual(localTime(instant, "America/New_York"), { date: "2026-03-08", hour: 8, weekday: 0 });
    assert.deepEqual(localTime(instant, "Pacific/Auckland"), { date: "2026-03-09", hour: 1, weekday: 1 });
    assert.equal(localTime(new Date("2026-06-01T12:00:00Z"), "Asia/Kolkata").hour, 17);
    assert.equal(localTime(instant, undefined), null);
    assert.equal(localTime(instant, "Not/AZone"), null);
});

test("the streak reminder is due only in the user's reminder hour, defaulting to 19", () => {
    const settings = { fcm_token: "tok", timezone: "America/New_York", reminder_hour: 20 };
    // 20:00 EST in winter is 01:00Z; after the change 20:00 EDT is 00:00Z.
    assert.equal(isStreakReminderDue(settings, new Date("2026-01-15T01:00:00Z")), true);
    assert.equal(isStreakReminderDue(settings, new Date("2026-01-15T00:00:00Z")), false);
    assert.equal(isStreakReminderDue(settings, new Date("2026-07-15T00:00:00Z")), true);
    assert.equal(isStreakReminderDue({ fcm_token: "tok", timezone: "Europe/London" }, new Date("2026-01-15T19:00:00Z")), true);
    assert.equal(isStreakReminderDue({ ...settings, social_push_streak_reminder: false }, new Date("2026-01-15T01:00:00Z")), false);
    assert.equal(isStreakReminderDue({ timezone: "Europe/London", reminder_hour: 19 }, new Date("2026-01-15T19:00:00Z")), false);
    assert.equal(isStreakReminderDue(null, new Date()), false);
});

test("buildStreakReminderPush fires when the last workout was yesterday on the user's clock", () => {
    const settings = { fcm_token: "tok", timezone: "Australia/Sydney", reminder_hour: 19 };
    const now = new Date("2026-01-15T08:00:00Z"); // 19:00 AEDT on the 15th
    const push = buildStreakReminderPush(settings, { current_streak: 5, date_last_event: new Date("2026-01-14T09:00:00Z") }, now);
    assert.deepEqual(push.notification, { title: "Streak at risk", body: "Your 5-day streak ends at midnight" });
    assert.deepEqual(push.data, { tab: "training", type: "streakReminder" });
    assert.equal(push.token, "tok");
    // A Firestore Timestamp is read through toDate().
    assert.ok(buildStreakReminderPush(settings, { current_streak: 5, date_last_event: { toDate: () => new Date("2026-01-14T09:00:00Z") } }, now));

    // Trained today (the 15th local, although still the 14th in UTC): no push.
    assert.equal(buildStreakReminderPush(settings, { current_streak: 5, date_last_event: new Date("2026-01-14T22:00:00Z") }, now), null);
    // Last workout two days ago: the streak has already gone.
    assert.equal(buildStreakReminderPush(settings, { current_streak: 5, date_last_event: new Date("2026-01-13T09:00:00Z") }, now), null);
    assert.equal(buildStreakReminderPush(settings, { current_streak: 0, date_last_event: new Date("2026-01-14T09:00:00Z") }, now), null);
    assert.equal(buildStreakReminderPush(settings, undefined, now), null);
    assert.equal(buildStreakReminderPush(settings, { current_streak: 5, date_last_event: new Date("2026-01-14T09:00:00Z") }, new Date("2026-01-15T09:00:00Z")), null);
});

test("the weekly digest is due at 18:00 on Sunday local time only", () => {
    const settings = { fcm_token: "tok", timezone: "America/Los_Angeles" };
    assert.equal(isWeeklyDigestDue(settings, new Date("2026-01-19T02:00:00Z")), true); // Sun 18:00 PST
    assert.equal(isWeeklyDigestDue(settings, new Date("2026-07-20T01:00:00Z")), true); // Sun 18:00 PDT
    assert.equal(isWeeklyDigestDue(settings, new Date("2026-01-18T18:00:00Z")), false); // Sun 10:00 PST
    assert.equal(isWeeklyDigestDue({ fcm_token: "tok", timezone: "Europe/London" }, new Date("2026-01-17T18:00:00Z")), false); // Saturday
    assert.equal(isWeeklyDigestDue({ ...settings, social_push_weekly_digest: false }, new Date("2026-01-19T02:00:00Z")), false);
});

test("the digest counts real sessions and needs someone followed", () => {
    assert.equal(countTrainingSessions([{}, { deleted_at: new Date() }, { is_rest_day: true }, { is_rest_day: false }]), 2);
    assert.equal(countTrainingSessions(undefined), 0);
    assert.equal(digestWindowStart(new Date("2026-01-18T18:00:00Z")).toISOString(), "2026-01-11T18:00:00.000Z");

    const push = buildWeeklyDigestPush({ fcm_token: "tok" }, { mine: 3, circle: 11, followingCount: 2 });
    assert.equal(push.notification.body, "This week: you trained 3 times, your circle 11");
    assert.deepEqual(push.data, { tab: "dashboard", type: "weeklyDigest" });
    assert.equal(buildWeeklyDigestPush({ fcm_token: "tok" }, { mine: 1, circle: 0, followingCount: 1 }).notification.body,
        "This week: you trained 1 time, your circle 0");
    assert.equal(buildWeeklyDigestPush({ fcm_token: "tok" }, { mine: 3, circle: 0, followingCount: 0 }), null);
    assert.equal(buildWeeklyDigestPush({}, { mine: 3, circle: 1, followingCount: 1 }), null);
});

test("isNudgeOnCooldown holds for just under 24 hours after the last nudge", () => {
    const now = new Date("2026-01-15T00:01:00Z");
    const hoursAgo = (h) => new Date(now.getTime() - h * 3600 * 1000);
    assert.equal(isNudgeOnCooldown(hoursAgo(0.05), now), true);
    assert.equal(isNudgeOnCooldown({ toDate: () => hoursAgo(23.99) }, now), true);
    assert.equal(isNudgeOnCooldown(hoursAgo(24), now), false);
    assert.equal(isNudgeOnCooldown(hoursAgo(30), now), false);
    assert.equal(isNudgeOnCooldown(undefined, now), false);
});

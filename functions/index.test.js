import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import {
    buildActivityPush, buildFollowAcceptedNotification, cleanJson, followAcceptedMessage, newlyBlockedIds, normaliseName,
    planFollowAccepted, pushRecipientSettings, requireAuth, userDisplayName,
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
    assert.equal(callables.length, 6, "expected six callables");
    for (const [, name, options, firstLine] of callables) {
        assert.equal(options.trim(), "CALLABLE_OPTIONS", `${name} must use CALLABLE_OPTIONS`);
        assert.match(firstLine, /requireAuth\(request\)/, `${name} must call requireAuth first`);
    }
});

test("each deployed callable rejects an unauthenticated request before doing any work", async () => {
    const fns = await import("./index.js");
    for (const name of ["foodAnalyze", "mealDescribe", "nutritionLabelAnalyze", "chatGenerate", "imageGenerate", "foodSearch"]) {
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
        social_push_nudges: undefined, social_push_mentions: undefined,
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
    assert.deepEqual(nudge.data, { tab: "dashboard", type: "nudge", session_id: "", actor_id: "a1" });
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

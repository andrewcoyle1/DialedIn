import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { buildActivityPush, cleanJson, normaliseName, requireAuth } from "./lib.js";

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
    const like = buildActivityPush({ type: "like", actor_name: "Jane", session_id: "s1", actor_id: "a1" }, recipient);
    assert.equal(like.token, "tok");
    assert.deepEqual(like.notification, { title: "New like", body: "Jane liked your workout" });
    assert.deepEqual(like.data, { tab: "dashboard", type: "like", session_id: "s1", actor_id: "a1" });

    const comment = buildActivityPush({ type: "comment", actor_name: "Jane", comment_text: "Nice!" }, recipient);
    assert.deepEqual(comment.notification, { title: "New comment", body: "Jane commented: Nice!" });

    const follow = buildActivityPush({ type: "follow", actor_name: "Jane" }, recipient);
    assert.deepEqual(follow.notification, { title: "New follower", body: "Jane started following you" });
    assert.equal(follow.data.session_id, "");

    assert.equal(buildActivityPush({ type: "like" }, recipient).notification.body, "Someone liked your workout");
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
    assert.equal(buildActivityPush({ type: "mention" }, { fcm_token: "tok" }), null);
    assert.equal(buildActivityPush({ type: "like" }, { fcm_token: "tok", social_push_likes: false }), null);
    assert.equal(buildActivityPush({ type: "comment" }, { fcm_token: "tok", social_push_comments: false }), null);
    assert.equal(buildActivityPush({ type: "follow" }, { fcm_token: "tok", social_push_follows: false }), null);
    assert.equal(buildActivityPush({ type: "nudge" }, { fcm_token: "tok", social_push_nudges: false }), null);
    // Opting out of one type leaves the others on.
    assert.notEqual(buildActivityPush({ type: "follow" }, { fcm_token: "tok", social_push_likes: false }), null);
});

test("buildActivityPush turns a nudge into a push with no session behind it", () => {
    const nudge = buildActivityPush({ type: "nudge", actor_name: "Jane", actor_id: "a1" }, { fcm_token: "tok" });
    assert.deepEqual(nudge.notification, { title: "Nudge", body: "Jane nudged you to train" });
    assert.deepEqual(nudge.data, { tab: "dashboard", type: "nudge", session_id: "", actor_id: "a1" });
});

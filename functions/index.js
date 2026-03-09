const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { GoogleAuth } = require("google-auth-library");

initializeApp();

const PROJECT_ID = "dialed-c3cb5";
const FCM_URL = `https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send`;

const auth = new GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
});

async function sendPush(fcmToken, title, body, extraData) {
    const client = await auth.getClient();
    const tokenResult = await client.getAccessToken();
    const accessToken = tokenResult.token;

    console.log(`Obtained access token: ${accessToken ? "YES" : "NO"}`);

    const message = {
        token: fcmToken,
        notification: { title, body },
        apns: {
            payload: {
                aps: { badge: 1, sound: "default" },
            },
        },
        data: extraData,
    };

    const response = await fetch(FCM_URL, {
        method: "POST",
        headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ message }),
    });

    const responseText = await response.text();
    if (!response.ok) {
        throw new Error(`FCM HTTP ${response.status}: ${responseText}`);
    }
    return responseText;
}

/**
 * Fires when a new activity notification document is created under
 * users/{userId}/notifications/{notificationId}.
 * Looks up the recipient's FCM token and sends a push notification.
 */
exports.onActivityNotificationCreated = onDocumentCreated(
    "users/{userId}/notifications/{notificationId}",
    async (event) => {
        const snap = event.data;
        if (!snap) return null;

        const data = snap.data();
        const userId = event.params.userId;

        const db = getFirestore();
        const userDoc = await db.collection("users").doc(userId).get();
        const fcmToken = userDoc.data()?.fcm_token;

        if (!fcmToken) {
            console.log(`No FCM token for user ${userId} — skipping push.`);
            return null;
        }

        const isLike = data.type === "like";
        const actorName = data.actor_name || "Someone";
        const commentText = data.comment_text || "";

        const title = isLike ? "New Like" : "New Comment";
        const body = isLike
            ? `${actorName} liked your workout`
            : `${actorName} commented: "${commentText.substring(0, 60)}"`;

        try {
            const result = await sendPush(fcmToken, title, body, {
                type: data.type || "",
                session_id: data.session_id || "",
                actor_id: data.actor_id || "",
            });
            console.log(`Push sent to user ${userId} for ${data.type}: ${result}`);
        } catch (error) {
            console.error(`Error sending push to user ${userId}: ${error.message}`);
        }

        return null;
    }
);

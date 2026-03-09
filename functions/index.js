const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
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
 * Callable function that proxies food searches to Open Food Facts.
 * Filters out products with no name and normalises the nutriment fields.
 */
const CACHE_TTL_MS = 7 * 24 * 60 * 60 * 1000; // 7 days

exports.foodSearch = onCall({ region: "us-central1" }, async (request) => {
    const query = request.data.query;
    if (!query || typeof query !== "string" || query.trim().length === 0) {
        throw new HttpsError("invalid-argument", "query is required");
    }

    const trimmed = query.trim();
    const db = getFirestore();
    const cacheKey = trimmed.toLowerCase().replace(/\s+/g, "_");
    const cacheRef = db.collection("food_search_cache").doc(cacheKey);

    // Check cache
    const cached = await cacheRef.get();
    if (cached.exists) {
        const data = cached.data();
        const age = Date.now() - data.cachedAt.toMillis();
        if (age < CACHE_TTL_MS) {
            cacheRef.update({ hitCount: FieldValue.increment(1) }); // fire-and-forget
            console.log(`Cache HIT: "${trimmed}" (${data.products.length} results, age=${Math.round(age / 3600000)}h)`);
            return { products: data.products };
        }
    }

    // Cache miss — fetch from OFF v2 API.
    // - states_tags: only products with verified complete nutrition facts
    // - sort_by=unique_scans_n: most-scanned (most real-world, popular) products first
    // - Fetch 50 so we have enough after name-relevance post-filtering, then cap at 20
    const url = new URL("https://world.openfoodfacts.org/api/v2/search");
    url.searchParams.set("search_terms", trimmed);
    url.searchParams.set("fields", "product_name,brands,nutriments");
    url.searchParams.set("page_size", "50");
    url.searchParams.set("sort_by", "unique_scans_n");

    let response;
    try {
        response = await fetch(url.toString(), {
            headers: { "User-Agent": "DialedIn/1.0 (nutrition tracking app; contact@dialedinapp.com)" },
        });
    } catch (err) {
        throw new HttpsError("unavailable", `Network error reaching Open Food Facts: ${err.message}`);
    }

    if (!response.ok) {
        throw new HttpsError("unavailable", `Open Food Facts returned HTTP ${response.status}`);
    }

    // Post-filter: name must contain at least one query word (drops unrelated noise).
    // Single-character words are skipped (articles, etc.).
    const queryWords = trimmed.toLowerCase().split(/\s+/).filter(w => w.length > 1);
    const isRelevant = (name) => {
        if (queryWords.length === 0) return true;
        const lower = name.toLowerCase();
        return queryWords.some(w => lower.includes(w));
    };

    const json = await response.json();
    const products = (json.products ?? [])
        .filter(p => p.product_name && p.product_name.trim().length > 0)
        .filter(p => isRelevant(p.product_name))
        .slice(0, 20)
        .map(p => ({
            name: p.product_name.trim(),
            brandName: p.brands ?? null,
            calories: p.nutriments?.["energy-kcal_100g"] ?? null,
            protein: p.nutriments?.["proteins_100g"] ?? null,
            carbs: p.nutriments?.["carbohydrates_100g"] ?? null,
            fatTotal: p.nutriments?.["fat_100g"] ?? null,
            fatSaturated: p.nutriments?.["saturated-fat_100g"] ?? null,
            fiber: p.nutriments?.["fiber_100g"] ?? null,
            sugar: p.nutriments?.["sugars_100g"] ?? null,
            sodiumMg: p.nutriments?.["sodium_100g"] != null
                ? p.nutriments["sodium_100g"] * 1000 : null,
            potassiumMg: p.nutriments?.["potassium_100g"] ?? null,
            calciumMg: p.nutriments?.["calcium_100g"] ?? null,
            ironMg: p.nutriments?.["iron_100g"] ?? null,
        }));

    // Store in cache (fire-and-forget — don't block response)
    cacheRef.set({
        query: trimmed,
        products,
        cachedAt: FieldValue.serverTimestamp(),
        hitCount: 0,
    });

    console.log(`Cache MISS: "${trimmed}" — fetched ${products.length} from OFF`);
    return { products };
});

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

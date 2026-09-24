import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getMessaging } from "firebase-admin/messaging";
import {
    requireAuth, cleanJson, normaliseName, buildActivityPush, newlyBlockedIds, pushRecipientSettings,
    planFollowAccepted, buildFollowAcceptedNotification,
} from "./lib.js";
import { genkit } from "genkit";
import { vertexAI, gemini20Flash, imagen3Fast } from "@genkit-ai/vertexai";

initializeApp();

const PROJECT_ID = "dialed-c3cb5";
const REGION = "us-central1";

// Every callable requires a valid App Check token, so only genuine app instances
// (attested via App Attest, or an allowlisted debug token) can invoke them. These
// functions spend Vertex AI quota and write with Admin SDK privileges, which bypass
// Firestore rules, so they cannot be left open to arbitrary HTTPS callers.
const CALLABLE_OPTIONS = { region: REGION, enforceAppCheck: true };


// ---------------------------------------------------------------------------
// Genkit / Firebase AI Logic setup
// ---------------------------------------------------------------------------

const ai = genkit({
    plugins: [vertexAI({ projectId: PROJECT_ID, location: REGION })],
});


async function findOrCreateIngredient(uid, item) {
    const db = getFirestore();
    const collectionRef = db.collection("users").doc(uid).collection("ingredient_templates");
    const nameLower = normaliseName(item.name);

    // Primary: name_lower field (on all docs created by this function)
    const primarySnap = await collectionRef.where("name_lower", "==", nameLower).limit(1).get();
    if (!primarySnap.empty) return primarySnap.docs[0].data().ingredient_id;

    // Fallback: exact name match (handles legacy docs without name_lower)
    const fallbackSnap = await collectionRef.where("name", "==", item.name.trim()).limit(1).get();
    if (!fallbackSnap.empty) return fallbackSnap.docs[0].data().ingredient_id;

    // Not found — create new ingredient (nutrition per 100g)
    const ingredientId = collectionRef.doc().id;
    const amountGrams = item.amountGrams > 0 ? item.amountGrams : 100;
    const per100g = (v) => (v != null ? (v / amountGrams) * 100 : null);
    const now = new Date();

    await collectionRef.doc(ingredientId).set({
        ingredient_id: ingredientId,
        author_id: uid,
        name: item.name.trim(),
        name_lower: nameLower,
        brand_name: null,
        description: null,
        measurement_method: "weight",
        calories: per100g(item.calories ?? null),
        protein: per100g(item.proteinGrams ?? null),
        carbs: per100g(item.carbGrams ?? null),
        fat_total: per100g(item.fatGrams ?? null),
        date_created: now,
        date_modified: now,
    });

    console.log(`Created ingredient "${item.name}" (id=${ingredientId}) for user ${uid}`);
    return ingredientId;
}

// Prompts shared across food-analysis functions
const FOOD_ITEMS_SCHEMA = `{
  "items": [
    {
      "id": "1",
      "name": "Food name",
      "amountGrams": 150,
      "calories": 248,
      "proteinGrams": 46.5,
      "carbGrams": 0,
      "fatGrams": 5.4
    }
  ]
}`;

const FOOD_LABEL_SCHEMA = `{
  "name": "Product Name",
  "measurementMethod": "weight",
  "calories": 380,
  "protein": 30.0,
  "carbs": 45.0,
  "fatTotal": 5.0,
  "fatSaturated": 1.5,
  "fiber": 3.0,
  "sugar": 8.0,
  "sodiumMg": 250,
  "potassiumMg": 420,
  "calciumMg": 200,
  "ironMg": 2.5
}`;

// ---------------------------------------------------------------------------
// AI: Analyse food from a photo
// ---------------------------------------------------------------------------

export const foodAnalyze = onCall(CALLABLE_OPTIONS, async (request) => {
    const uid = requireAuth(request);
    const { imageBase64 } = request.data;
    if (!imageBase64 || typeof imageBase64 !== "string") {
        throw new HttpsError("invalid-argument", "imageBase64 is required");
    }

    const systemPrompt = `You are a nutrition expert. Analyse the food in the image.
Return ONLY valid JSON matching this exact schema — no markdown fences, no extra text:
${FOOD_ITEMS_SCHEMA}
Include every distinct food item visible. Estimate realistic portion sizes in grams and
calculate macronutrients per portion. All numeric fields must be numbers, not strings.`;

    const { text } = await ai.generate({
        model: gemini20Flash,
        prompt: [
            {
                media: {
                    url: `data:image/jpeg;base64,${imageBase64}`,
                    contentType: "image/jpeg",
                },
            },
            { text: systemPrompt },
        ],
        config: { responseMimeType: "application/json" },
    });

    const parsed = JSON.parse(cleanJson(text));

    if (Array.isArray(parsed.items)) {
        const resolvedItems = await Promise.all(
            parsed.items.map(async (item) => ({
                ...item,
                ingredientId: await findOrCreateIngredient(uid, item),
            }))
        );
        return { result: JSON.stringify({ items: resolvedItems }) };
    }

    return { result: cleanJson(text) };
});

// ---------------------------------------------------------------------------
// AI: Describe a meal in plain text → structured food items
// ---------------------------------------------------------------------------

export const mealDescribe = onCall(CALLABLE_OPTIONS, async (request) => {
    const uid = requireAuth(request);
    const { description } = request.data;
    if (!description || typeof description !== "string" || description.trim().length === 0) {
        throw new HttpsError("invalid-argument", "description is required");
    }

    const prompt = `You are a nutrition expert. The user described their meal as:
"${description.trim()}"

Break it down into individual food components and return ONLY valid JSON matching this exact
schema — no markdown fences, no extra text:
${FOOD_ITEMS_SCHEMA}
Estimate realistic portion sizes in grams and calculate macronutrients per component.
All numeric fields must be numbers, not strings.`;

    const { text } = await ai.generate({
        model: gemini20Flash,
        prompt,
        config: { responseMimeType: "application/json" },
    });

    const parsed = JSON.parse(cleanJson(text));

    if (Array.isArray(parsed.items)) {
        const resolvedItems = await Promise.all(
            parsed.items.map(async (item) => ({
                ...item,
                ingredientId: await findOrCreateIngredient(uid, item),
            }))
        );
        return { result: JSON.stringify({ items: resolvedItems }) };
    }

    return { result: cleanJson(text) };
});

// ---------------------------------------------------------------------------
// AI: Extract structured data from a nutrition label
// ---------------------------------------------------------------------------

export const nutritionLabelAnalyze = onCall(CALLABLE_OPTIONS, async (request) => {
    requireAuth(request);
    const { labelText } = request.data;
    if (!labelText || typeof labelText !== "string" || labelText.trim().length === 0) {
        throw new HttpsError("invalid-argument", "labelText is required");
    }

    const prompt = `You are a nutrition expert. Extract all nutrition information from the
following label text and return ONLY valid JSON matching this exact schema — no markdown
fences, no extra text:
${FOOD_LABEL_SCHEMA}
Use null for any field that is not present in the label.
measurementMethod should be "weight" (per grams) or "volume" (per mL).
All numeric values must be numbers, not strings.

Label text:
${labelText.trim()}`;

    const { text } = await ai.generate({
        model: gemini20Flash,
        prompt,
        config: { responseMimeType: "application/json" },
    });

    return { result: cleanJson(text) };
});

// ---------------------------------------------------------------------------
// AI: General chat (Gemini)
// ---------------------------------------------------------------------------

export const chatGenerate = onCall(CALLABLE_OPTIONS, async (request) => {
    requireAuth(request);
    const { messages, temperature = 0.7, maxOutputTokens = 512 } = request.data;
    if (!Array.isArray(messages) || messages.length === 0) {
        throw new HttpsError("invalid-argument", "messages array is required");
    }

    // Build Genkit message history
    const history = messages.slice(0, -1).map((m) => ({
        role: m.role === "assistant" ? "model" : "user",
        content: [{ text: m.message }],
    }));
    const last = messages[messages.length - 1];

    const { text } = await ai.generate({
        model: gemini20Flash,
        messages: history,
        prompt: last.message,
        config: { temperature, maxOutputTokens },
    });

    return { role: "assistant", message: text.trim() };
});

// ---------------------------------------------------------------------------
// AI: Image generation (Imagen 3 via Vertex AI)
// ---------------------------------------------------------------------------

export const imageGenerate = onCall(CALLABLE_OPTIONS, async (request) => {
    requireAuth(request);
    const { prompt } = request.data;
    if (!prompt || typeof prompt !== "string" || prompt.trim().length === 0) {
        throw new HttpsError("invalid-argument", "prompt is required");
    }

    const response = await ai.generate({
        model: imagen3Fast,
        prompt: prompt.trim(),
        output: { format: "media" },
    });

    const mediaUrl = response.media?.url;
    if (!mediaUrl) {
        throw new HttpsError("internal", "No image returned from Imagen");
    }

    // mediaUrl is a data URI: "data:image/png;base64,<base64>"
    const base64 = mediaUrl.split(",")[1];
    return { base64 };
});

// ---------------------------------------------------------------------------
// Food search (proxies Open Food Facts with Firestore caching)
// ---------------------------------------------------------------------------

const CACHE_TTL_MS = 7 * 24 * 60 * 60 * 1000; // 7 days

export const foodSearch = onCall(CALLABLE_OPTIONS, async (request) => {
    requireAuth(request);
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
            cacheRef.update({ hitCount: FieldValue.increment(1) });
            console.log(`Cache HIT: "${trimmed}" (${data.products.length} results, age=${Math.round(age / 3600000)}h)`);
            return { products: data.products };
        }
    }

    const url = new URL("https://world.openfoodfacts.org/api/v2/search");
    url.searchParams.set("search_terms", trimmed);
    url.searchParams.set("fields", "product_name,brands,nutriments,serving_size,serving_quantity,image_front_small_url");
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

    const queryWords = trimmed.toLowerCase().split(/\s+/).filter((w) => w.length > 1);
    const isRelevant = (name) => {
        if (queryWords.length === 0) return true;
        const lower = name.toLowerCase();
        return queryWords.some((w) => lower.includes(w));
    };

    const json = await response.json();
    const products = (json.products ?? [])
        .filter((p) => p.product_name && p.product_name.trim().length > 0)
        .filter((p) => isRelevant(p.product_name))
        .slice(0, 20)
        .map((p) => ({
            name: p.product_name.trim(),
            brandName: p.brands ?? null,
            imageURL: p.image_front_small_url ?? null,
            servingWeight: p.serving_quantity ?? null,
            servingSize: p.serving_size ?? null,
            calories: p.nutriments?.["energy-kcal_100g"] ?? null,
            protein: p.nutriments?.["proteins_100g"] ?? null,
            carbs: p.nutriments?.["carbohydrates_100g"] ?? null,
            fatTotal: p.nutriments?.["fat_100g"] ?? null,
            fatSaturated: p.nutriments?.["saturated-fat_100g"] ?? null,
            fiber: p.nutriments?.["fiber_100g"] ?? null,
            sugar: p.nutriments?.["sugars_100g"] ?? null,
            sodiumMg: p.nutriments?.["sodium_100g"] != null
                ? p.nutriments["sodium_100g"] * 1000
                : null,
            potassiumMg: p.nutriments?.["potassium_100g"] ?? null,
            calciumMg: p.nutriments?.["calcium_100g"] ?? null,
            ironMg: p.nutriments?.["iron_100g"] ?? null,
            vitaminAMcg: p.nutriments?.["vitamin-a_100g"] ?? null,
            vitaminB6Mg: p.nutriments?.["vitamin-b6_100g"] ?? null,
            vitaminB12Mcg: p.nutriments?.["vitamin-b12_100g"] ?? null,
            vitaminCMg: p.nutriments?.["vitamin-c_100g"] ?? null,
            vitaminDMcg: p.nutriments?.["vitamin-d_100g"] ?? null,
            vitaminEMg: p.nutriments?.["vitamin-e_100g"] ?? null,
            vitaminKMcg: p.nutriments?.["vitamin-k_100g"] ?? null,
            magnesiumMg: p.nutriments?.["magnesium_100g"] ?? null,
            zincMg: p.nutriments?.["zinc_100g"] ?? null,
            phosphorusMg: p.nutriments?.["phosphorus_100g"] ?? null,
            cholesterolMg: p.nutriments?.["cholesterol_100g"] ?? null,
            caffeineMg: p.nutriments?.["caffeine_100g"] ?? null,
            riboflavinMg: p.nutriments?.["riboflavin_100g"] ?? null,
            thiaminMg: p.nutriments?.["thiamin_100g"] ?? null,
            niacinMg: p.nutriments?.["niacin_100g"] ?? null,
            biotinMcg: p.nutriments?.["biotin_100g"] ?? null,
            folateMcg: p.nutriments?.["folates_100g"] ?? null,
            iodineMcg: p.nutriments?.["iodine_100g"] ?? null,
            seleniumMcg: p.nutriments?.["selenium_100g"] ?? null,
            manganeseMg: p.nutriments?.["manganese_100g"] ?? null,
            copperMg: p.nutriments?.["copper_100g"] ?? null,
            chlorideMg: p.nutriments?.["chloride_100g"] ?? null,
            pantothenicAcidMg: p.nutriments?.["pantothenic-acid_100g"] ?? null,
        }));

    cacheRef.set({
        query: trimmed,
        products,
        cachedAt: FieldValue.serverTimestamp(),
        hitCount: 0,
    });

    console.log(`Cache MISS: "${trimmed}" — fetched ${products.length} from OFF`);
    return { products };
});

// ---------------------------------------------------------------------------
// FCM push for social activity (likes / comments / mentions / follows / nudges)
// ---------------------------------------------------------------------------

// The app writes users/{uid}/notifications for the in-app bell; this turns each new doc into a
// push so it still arrives when the app is closed. The token and opt-outs are private to the owner,
// in users/{uid}/private/settings; pushRecipientSettings falls back to the legacy user-doc fields.
// Message building and the opt-out check live in lib.js so they can be tested without Firestore.
export const onActivityNotificationCreated = onDocumentCreated(
    { document: "users/{userId}/notifications/{notificationId}", region: REGION },
    async (event) => {
        const notification = event.data?.data();
        if (!notification) return;

        const userId = event.params.userId;
        const userRef = getFirestore().collection("users").doc(userId);
        const [userDoc, privateDoc] = await Promise.all([
            userRef.get(),
            userRef.collection("private").doc("settings").get(),
        ]);
        const recipient = pushRecipientSettings(privateDoc.data(), userDoc.data());
        const message = buildActivityPush(notification, recipient);
        if (!message) {
            console.log(`No push for user ${userId} (${notification.type}): no token or opted out.`);
            return;
        }

        try {
            await getMessaging().send(message);
        } catch (error) {
            console.error(`Error sending push to user ${userId}: ${error.message}`);
        }
    }
);

// ---------------------------------------------------------------------------
// Blocking: end the blocked person's follow
// ---------------------------------------------------------------------------

// A follow lives in the follower's own following_ids, which the blocker cannot write and rules
// cannot refuse on the blocker's behalf. So when users/{uid}.blocked_user_ids gains an id, this
// takes uid out of that person's following_ids and drops any pending follow request they sent.
// The blocked person's document changing re-fires this trigger, but their block list is unchanged,
// so it returns at once.
export const onUserBlockListChanged = onDocumentUpdated(
    { document: "users/{uid}", region: REGION },
    async (event) => {
        const blocked = newlyBlockedIds(event.data?.before?.data(), event.data?.after?.data());
        if (blocked.length === 0) return;

        const uid = event.params.uid;
        const users = getFirestore().collection("users");
        const results = await Promise.allSettled(blocked.flatMap((blockedId) => [
            // update, not set: a deleted account must not come back as a stub document.
            users.doc(blockedId).update({ following_ids: FieldValue.arrayRemove(uid) }),
            // A no-op when there is no request, or no follow_requests collection at all.
            users.doc(uid).collection("follow_requests").doc(blockedId).delete(),
        ]));
        for (const result of results) {
            if (result.status === "rejected") {
                console.error(`Block cleanup for user ${uid}: ${result.reason?.message}`);
            }
        }
    }
);

// ---------------------------------------------------------------------------
// Follow requests to private profiles
// ---------------------------------------------------------------------------

// The target of a request accepts it by setting status to "accepted", but a client can only write
// its own users/{uid} document, so the follow itself is written here: the target joins the
// requester's following_ids, the requester gets a followAccepted notification (which
// onActivityNotificationCreated turns into a push), and the request is deleted. A declined request
// is left for the requester to see as declined; nothing else happens.
export const onFollowRequestUpdated = onDocumentUpdated(
    { document: "users/{targetId}/follow_requests/{requesterId}", region: REGION },
    async (event) => {
        const plan = planFollowAccepted(event.data?.before?.data(), event.data?.after?.data(), event.params);
        if (!plan) return;

        const db = getFirestore();
        const targetDoc = await db.collection("users").doc(plan.targetId).get();
        const batch = db.batch();
        batch.update(db.collection("users").doc(plan.requesterId), {
            following_ids: FieldValue.arrayUnion(plan.targetId),
        });
        batch.set(
            db.collection("users").doc(plan.requesterId).collection("notifications").doc(plan.notificationId),
            buildFollowAcceptedNotification(targetDoc.data(), plan)
        );
        batch.delete(event.data.after.ref);
        await batch.commit();
    }
);

// ---------------------------------------------------------------------------
// Usernames
// ---------------------------------------------------------------------------

import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { planUsernameRelease, shouldReleaseReservation } from "./lib.js";

// The app reserves usernames/{handle} before setting users/{uid}.username, and rules only let the
// owner delete a reservation. When a username changes, or the account is deleted, the old handle is
// released here so someone else can claim it. Written, not just updated, so deletion is covered too.
export const onUsernameChanged = onDocumentWritten(
    { document: "users/{uid}", region: REGION },
    async (event) => {
        const handle = planUsernameRelease(event.data?.before?.data(), event.data?.after?.data());
        if (!handle) return;

        const db = getFirestore();
        const ref = db.collection("usernames").doc(handle);
        await db.runTransaction(async (tx) => {
            const snap = await tx.get(ref);
            if (snap.exists && shouldReleaseReservation(snap.data(), event.params.uid)) {
                tx.delete(ref);
            }
        });
    }
);

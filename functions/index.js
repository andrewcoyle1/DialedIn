import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { GoogleAuth } from "google-auth-library";
import { genkit } from "genkit";
import { vertexAI, gemini20Flash, imagen3Fast } from "@genkit-ai/vertexai";

initializeApp();

const PROJECT_ID = "dialed-c3cb5";
const REGION = "us-central1";
const FCM_URL = `https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send`;

// ---------------------------------------------------------------------------
// Genkit / Firebase AI Logic setup
// ---------------------------------------------------------------------------

const ai = genkit({
    plugins: [vertexAI({ projectId: PROJECT_ID, location: REGION })],
});

// Strip markdown code fences Gemini sometimes wraps JSON in
function cleanJson(text) {
    return text.replace(/^```(?:json)?\s*/i, "").replace(/\s*```$/, "").trim();
}

function normaliseName(name) {
    return name.trim().toLowerCase();
}

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

export const foodAnalyze = onCall({ region: REGION }, async (request) => {
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

    if (request.auth && Array.isArray(parsed.items)) {
        const uid = request.auth.uid;
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

export const mealDescribe = onCall({ region: REGION }, async (request) => {
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

    if (request.auth && Array.isArray(parsed.items)) {
        const uid = request.auth.uid;
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

export const nutritionLabelAnalyze = onCall({ region: REGION }, async (request) => {
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

export const chatGenerate = onCall({ region: REGION }, async (request) => {
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

export const imageGenerate = onCall({ region: REGION }, async (request) => {
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

export const foodSearch = onCall({ region: REGION }, async (request) => {
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
// FCM push notifications for activity (likes / comments)
// ---------------------------------------------------------------------------

const fcmAuth = new GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
});

async function sendPush(fcmToken, title, body, extraData) {
    const client = await fcmAuth.getClient();
    const tokenResult = await client.getAccessToken();
    const accessToken = tokenResult.token;

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

    const res = await fetch(FCM_URL, {
        method: "POST",
        headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ message }),
    });

    const responseText = await res.text();
    if (!res.ok) {
        throw new Error(`FCM HTTP ${res.status}: ${responseText}`);
    }
    return responseText;
}

export const onActivityNotificationCreated = onDocumentCreated(
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

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

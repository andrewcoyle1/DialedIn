//
//  GoogleAIService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/09/2025.
//

import SwiftUI
@preconcurrency import FirebaseFunctions
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseAppCheck
import Foundation

struct GoogleAIService: AIService {
    private let functions: Functions
    
    init(functions: Functions = Functions.functions(region: "us-central1")) {
        self.functions = functions
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await ensureAuthenticated()
        try await ensureValidIDToken()
        _ = try await AppCheckTokenCache.shared.getToken()
        let payload: NSDictionary = [
            "prompt": input
        ]
        let callable = functions.httpsCallable("imageGenerate")
        let result = try await callable.call(payload)
        guard let dict = result.data as? [String: Any],
              let base64 = dict["base64"] as? String,
              let data = Data(base64Encoded: base64),
              let image = UIImage(data: data) else {
            throw GoogleAIError.invalidResponse
        }
        return image
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await ensureAuthenticated()
        try await ensureValidIDToken()
        _ = try await AppCheckTokenCache.shared.getToken()
        let messages: [NSDictionary] = chats.map { chat in
            [
                "role": chat.role.rawValue,
                "message": chat.message
            ] as NSDictionary
        }
        let payload: NSDictionary = [
            "messages": messages,
            "temperature": 0.7,
            "maxOutputTokens": 512
        ]
        let callable = functions.httpsCallable("chatGenerate")
        let result = try await callable.call(payload)
        guard let dict = result.data as? [String: Any],
              let role = dict["role"] as? String,
              let message = dict["message"] as? String,
              let aiRole = AIChatRole(rawValue: role) else {
            throw GoogleAIError.invalidResponse
        }
        return AIChatModel(role: aiRole, content: message)
    }
    
    enum GoogleAIError: LocalizedError {
        case invalidResponse
    }
}

private func ensureAuthenticated() async throws {
    if Auth.auth().currentUser != nil { return }
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        Auth.auth().signInAnonymously { _, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume()
            }
        }
    }
}

private func ensureValidIDToken() async throws {
    guard let user = Auth.auth().currentUser else { return }
    _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
        user.getIDTokenForcingRefresh(false) { token, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: token ?? "")
            }
        }
    }
}

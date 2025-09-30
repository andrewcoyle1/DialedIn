//
//  AppCheckTokenCache.swift
//  DialedIn
//
//  Created by Assistant on 29/09/2025.
//

import Foundation
@preconcurrency import FirebaseAppCheck

actor AppCheckTokenCache {
    static let shared = AppCheckTokenCache()

    private var cachedToken: AppCheckToken?
    private var lastFetchAt: Date?
    // Throttle token fetches to avoid hammering; SDK also caches internally.
    private let minFetchInterval: TimeInterval = 60

    func getToken() async throws -> AppCheckToken {
        if let token = cachedToken, let last = lastFetchAt, Date().timeIntervalSince(last) < minFetchInterval {
            return token
        }

        let token: AppCheckToken = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AppCheckToken, Error>) in
            AppCheck.appCheck().token(forcingRefresh: false) { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let token = token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: NSError(domain: "AppCheck", code: -1))
                }
            }
        }

        cachedToken = token
        lastFetchAt = Date()
        return token
    }

    func invalidate() {
        cachedToken = nil
        lastFetchAt = nil
    }
}

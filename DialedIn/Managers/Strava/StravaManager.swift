//
//  StravaManager.swift
//  DialedIn
//

import AuthenticationServices
import UIKit

@Observable
@MainActor
class StravaManager {

    private let service: StravaService
    private let clientId: String
    private let clientSecret: String
    private let contextProvider = StravaContextProvider()

    private var authSession: ASWebAuthenticationSession?

    var isConnected: Bool { KeychainHelper.read(forKey: "strava_access_token", synchronizable: true) != nil }
    var isUploading: Bool = false

    init(service: StravaService, clientId: String, clientSecret: String) {
        self.service = service
        self.clientId = clientId
        self.clientSecret = clientSecret
    }

    // MARK: - Auth

    func authenticate() async throws {
        let encodedClientId = clientId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? clientId
        let urlString = "https://www.strava.com/oauth/mobile/authorize?client_id=\(encodedClientId)&redirect_uri=dialedinostrava://localhost/exchange_token&response_type=code&approval_prompt=auto&scope=activity:write"
        guard let authURL = URL(string: urlString) else {
            throw StravaError.invalidURL
        }

        let code = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "dialedinostrava"
            ) { [weak self] callbackURL, error in
                self?.authSession = nil
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let callbackURL,
                      let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                        .queryItems?.first(where: { $0.name == "code" })?.value
                else {
                    continuation.resume(throwing: StravaError.missingAuthCode)
                    return
                }
                continuation.resume(returning: code)
            }
            session.presentationContextProvider = contextProvider
            session.prefersEphemeralWebBrowserSession = false
            authSession = session
            session.start()
        }

        let tokenResponse = try await service.exchangeCodeForToken(code: code, clientId: clientId, clientSecret: clientSecret)
        storeTokens(tokenResponse)
    }

    func disconnect() {
        KeychainHelper.delete(forKey: "strava_access_token")
        KeychainHelper.delete(forKey: "strava_refresh_token")
        KeychainHelper.delete(forKey: "strava_expires_at")
    }

    // MARK: - Upload

    func uploadWorkout(_ session: WorkoutSessionModel) async throws {
        guard let endedAt = session.endedAt else { return }

        let accessToken = try await validAccessToken()

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let activity = StravaActivity(
            name: session.name,
            sportType: "WeightTraining",
            startDateLocal: formatter.string(from: session.dateCreated),
            elapsedTime: Int(endedAt.timeIntervalSince(session.dateCreated)),
            description: session.notes
        )

        isUploading = true
        defer { isUploading = false }
        try await service.uploadActivity(activity, accessToken: accessToken)
    }

    func uploadTestActivity() async throws {
        let accessToken = try await validAccessToken()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let start = Date().addingTimeInterval(-1800)
        let activity = StravaActivity(
            name: "DialedIn Test Upload",
            sportType: "WeightTraining",
            startDateLocal: formatter.string(from: start),
            elapsedTime: 1800,
            description: "Test upload from DialedIn — safe to delete."
        )
        isUploading = true
        defer { isUploading = false }
        try await service.uploadActivity(activity, accessToken: accessToken)
    }

    // MARK: - Private Helpers

    private func validAccessToken() async throws -> String {
        guard let expiresAtString = KeychainHelper.read(forKey: "strava_expires_at", synchronizable: true),
              let expiresAt = Int(expiresAtString),
              let refreshToken = KeychainHelper.read(forKey: "strava_refresh_token", synchronizable: true) else {
            throw StravaError.notConnected
        }

        let now = Int(Date().timeIntervalSince1970)
        if now + 60 >= expiresAt {
            let tokenResponse = try await service.refreshToken(refreshToken: refreshToken, clientId: clientId, clientSecret: clientSecret)
            storeTokens(tokenResponse)
        }

        guard let accessToken = KeychainHelper.read(forKey: "strava_access_token", synchronizable: true) else {
            throw StravaError.notConnected
        }
        return accessToken
    }

    private func storeTokens(_ response: StravaTokenResponse) {
        KeychainHelper.save(response.accessToken, forKey: "strava_access_token", synchronizable: true)
        KeychainHelper.save(response.refreshToken, forKey: "strava_refresh_token", synchronizable: true)
        KeychainHelper.save(String(response.expiresAt), forKey: "strava_expires_at", synchronizable: true)
    }
}

// MARK: - Errors

enum StravaError: LocalizedError {
    case invalidURL
    case missingAuthCode
    case notConnected

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid Strava authorization URL."
        case .missingAuthCode: return "No authorization code was returned from Strava."
        case .notConnected: return "Not connected to Strava."
        }
    }
}

private class StravaContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
}

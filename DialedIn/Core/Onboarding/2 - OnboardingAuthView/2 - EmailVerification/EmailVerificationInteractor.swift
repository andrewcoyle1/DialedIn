//
//  EmailVerificationInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol EmailVerificationInteractor: Sendable {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    func sendVerificationEmail() async throws
    func checkVerificationEmail() async throws -> Bool
    func trackEvent(event: LoggableEvent)
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
}

extension CoreInteractor: EmailVerificationInteractor { }

//
//  SignUpInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol SignUpInteractor: Sendable {
    func createUser(email: String, password: String) async throws -> UserAuthInfo
    func logIn(auth: UserAuthInfo, image: PlatformImage?) async throws
    func trackEvent(event: LoggableEvent)
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
    func handleUserLoginError(_ error: Error) -> AuthErrorInfo
}

extension OnbInteractor: SignUpInteractor {
}

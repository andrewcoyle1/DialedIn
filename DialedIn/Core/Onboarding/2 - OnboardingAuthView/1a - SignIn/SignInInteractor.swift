//
//  SignInInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol SignInInteractor: Sendable {
    // var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    func signInUser(email: String, password: String) async throws -> UserAuthInfo
    func logIn(auth: UserAuthInfo, image: PlatformImage?) async throws
    func checkVerificationEmail() async throws -> Bool
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
    func handleUserLoginError(_ error: Error) -> AuthErrorInfo
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: SignInInteractor { }

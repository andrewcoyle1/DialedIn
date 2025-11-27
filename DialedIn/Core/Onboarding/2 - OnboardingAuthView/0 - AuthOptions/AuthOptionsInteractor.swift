//
//  AuthOptionsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol AuthOptionsInteractor {
    var currentUser: UserModel? { get }
    func signInApple() async throws -> UserAuthInfo
    func signInGoogle() async throws -> UserAuthInfo
    func logIn(auth: UserAuthInfo, image: PlatformImage?) async throws
    func handleAuthError(_ error: Error, operation: String, provider: String?) -> AuthErrorInfo
    func handleUserLoginError(_ error: Error) -> AuthErrorInfo
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: AuthOptionsInteractor { }

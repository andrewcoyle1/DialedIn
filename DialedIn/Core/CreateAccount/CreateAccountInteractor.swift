//
//  CreateAccountInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol CreateAccountInteractor {
    func trackEvent(event: LoggableEvent)
    func signInApple() async throws -> UserAuthInfo
    func signInGoogle() async throws -> UserAuthInfo
    func logIn(auth: UserAuthInfo, image: PlatformImage?) async throws
}

extension CoreInteractor: CreateAccountInteractor { }

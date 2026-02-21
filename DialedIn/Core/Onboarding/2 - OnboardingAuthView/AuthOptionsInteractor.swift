//
//  OnboardingAuthInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingAuthInteractor {
    var currentUser: UserModel? { get }
    var isPremium: Bool { get }
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(auth: UserAuthInfo, image: PlatformImage?, isNewUser: Bool) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingAuthInteractor { }

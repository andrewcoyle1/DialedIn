//
//  OnboardingAuthInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingAuthInteractor {
    var currentUser: UserModel? { get }
    var isPremium: Bool { get }
    func signInApple() async throws -> (UserAuthInfo, Bool)
    func signInGoogle() async throws -> (UserAuthInfo, Bool)
    func logIn(auth: UserAuthInfo, image: PlatformImage?, isNewUser: Bool) async throws
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingAuthInteractor { }

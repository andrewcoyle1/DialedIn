//
//  SettingsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol SettingsInteractor {
    var auth: UserAuthInfo? { get }
    func signOut() async throws
    func deleteCurrentUser() async throws
    func deleteUserProfile()
    func deleteAccount() async throws
    func reauthenticateApple() async throws
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: SettingsInteractor { }

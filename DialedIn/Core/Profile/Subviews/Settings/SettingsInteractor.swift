//
//  SettingsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol SettingsInteractor: GlobalInteractor {
    var auth: UserAuthInfo? { get }
    func signOut() async throws
    func deleteUserProfile()
    func deleteAccount() async throws
}

extension CoreInteractor: SettingsInteractor { }

//
//  ProfilePreferencesRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProfilePreferencesRouter {
    func showSettingsView()
    func showDevSettingsView()
}

extension CoreRouter: ProfilePreferencesRouter { }

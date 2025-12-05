//
//  ProfileRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProfileRouter {
    func showNotificationsView()
    func showDevSettingsView()
    func showSettingsView()
}

extension CoreRouter: ProfileRouter { }

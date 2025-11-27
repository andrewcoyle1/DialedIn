//
//  ProfileHeaderRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProfileHeaderRouter {
    func showProfileEditView()
    func showDevSettingsView()
}

extension CoreRouter: ProfileHeaderRouter { }

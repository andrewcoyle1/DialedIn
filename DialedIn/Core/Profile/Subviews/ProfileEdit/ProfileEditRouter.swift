//
//  ProfileEditRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProfileEditRouter {
    func showDevSettingsView()
    func showSimpleAlert(title: String, subtitle: String?)
    func dismissScreen()
}

extension CoreRouter: ProfileEditRouter { }

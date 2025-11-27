//
//  ProgramManagementRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProgramManagementRouter {
    func showDevSettingsView()
    func dismissScreen()

    func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
}

extension CoreRouter: ProgramManagementRouter { }

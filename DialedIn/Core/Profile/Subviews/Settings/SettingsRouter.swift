//
//  SettingsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol SettingsRouter {
    func showAlert(error: Error)
    func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
    func showCorePaywall()
    func dismissScreen()
}

extension CoreRouter: SettingsRouter { }

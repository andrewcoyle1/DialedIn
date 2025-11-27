//
//  SignUpRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol SignUpRouter {
    func showDevSettingsView()
    func showEmailVerificationView()

    func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
}

extension CoreRouter: SignUpRouter { }

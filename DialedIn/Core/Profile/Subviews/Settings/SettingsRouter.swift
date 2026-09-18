//
//  SettingsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol SettingsRouter: GlobalRouter {
    func showPaywall()
    func switchToOnboardingModule()
    func showPreferredDietView(isFromSettings: Bool)
    /// For upgrading an anonymous account — the same screen onboarding uses.
    func showAuthView()
}

extension CoreRouter: SettingsRouter { }

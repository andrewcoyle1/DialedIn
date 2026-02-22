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
}

extension CoreRouter: SettingsRouter { }

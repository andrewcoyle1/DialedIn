//
//  SettingsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol SettingsRouter: GlobalRouter {
    func showCorePaywall()
    func switchToOnboardingModule()
}

extension CoreRouter: SettingsRouter { }

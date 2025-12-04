//
//  EmailVerificationRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol EmailVerificationRouter {
    func showDevSettingsView()
    func showOnboardingCompleteAccountSetupView()
    func showOnboardingNotificationsView()
    func showOnboardingHealthDataView()
    func showOnboardingHealthDisclaimerView()
    func showOnboardingGoalSettingView()
    func showOnboardingCustomisingProgramView()
    func showOnboardingCompletedView()

    func dismissScreen()

    func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
}

extension OnbRouter: EmailVerificationRouter { }

//
//  OnboardingExpenditureRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol OnboardingExpenditureRouter {
    func showDevSettingsView()
    func showOnboardingNotificationsView()
    func showOnboardingHealthDataView()
    func showOnboardingHealthDisclaimerView()

    func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
}

extension CoreRouter: OnboardingExpenditureRouter { }

//
//  ExpenditureRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol ExpenditureRouter: GlobalRouter {
    func showDevSettingsView()
    func showNotificationsPermissionsView()
    func showOnboardingHealthDataView()
    func showHealthDisclaimerView()
}

extension CoreRouter: ExpenditureRouter { }

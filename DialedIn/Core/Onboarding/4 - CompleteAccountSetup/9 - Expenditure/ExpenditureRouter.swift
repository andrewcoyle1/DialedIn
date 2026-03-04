//
//  ExpenditureRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol ExpenditureRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showNotificationsPermissionsView()
    func showOnboardingHealthDataView()
    func showHealthDisclaimerView()
}

extension CoreRouter: ExpenditureRouter { }

//
//  DashboardRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol DashboardRouter {
    func showNotificationsView()
    func showDevSettingsView()
    func showCorePaywall()
    func showProfileView()
    func showLogWeightView()
}

extension CoreRouter: DashboardRouter { }

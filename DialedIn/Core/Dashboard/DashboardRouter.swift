//
//  DashboardRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol DashboardRouter {
    func showNotificationsView()
    func showDevSettingsView()
}

extension CoreRouter: DashboardRouter { }

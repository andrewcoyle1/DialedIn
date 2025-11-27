//
//  ProfilePhysicalMetricsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProfilePhysicalMetricsRouter {
    func showPhysicalStatsView()
    func showDevSettingsView()
}

extension CoreRouter: ProfilePhysicalMetricsRouter { }

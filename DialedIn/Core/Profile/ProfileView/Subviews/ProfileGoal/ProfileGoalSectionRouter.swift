//
//  ProfileGoalSectionRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProfileGoalSectionRouter {
    func showDevSettingsView()
    func showProfileGoalsView()
}

extension CoreRouter: ProfileGoalSectionRouter { }

//
//  ProgramGoalsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProgramGoalsRouter {
    func showAddGoalView(delegate: AddGoalDelegate)
    func showDevSettingsView()
}

extension CoreRouter: ProgramGoalsRouter { }

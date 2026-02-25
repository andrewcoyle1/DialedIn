//
//  OverarchingObjectiveRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OverarchingObjectiveRouter {
    func showDevSettingsView()
    func showTargetWeightView(delegate: TargetWeightDelegate)
    func showGoalSummaryView(delegate: GoalSummaryDelegate)
}

extension CoreRouter: OverarchingObjectiveRouter { }

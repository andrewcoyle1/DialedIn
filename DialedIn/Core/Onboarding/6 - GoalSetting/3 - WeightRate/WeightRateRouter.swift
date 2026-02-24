//
//  WeightRateRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WeightRateRouter {
    func showDevSettingsView()
    func showGoalSummaryView(delegate: GoalSummaryDelegate)
}

extension CoreRouter: WeightRateRouter { }

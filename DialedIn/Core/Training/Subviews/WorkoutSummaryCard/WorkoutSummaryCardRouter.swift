//
//  WorkoutSummaryCardRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WorkoutSummaryCardRouter {
    func showDevSettingsView()

    func showAlert(error: Error)
}

extension CoreRouter: WorkoutSummaryCardRouter { }

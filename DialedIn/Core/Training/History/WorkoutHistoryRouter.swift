//
//  WorkoutHistoryRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

@MainActor
protocol WorkoutHistoryRouter {
    func showDevSettingsView()
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate)

    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: WorkoutHistoryRouter { }

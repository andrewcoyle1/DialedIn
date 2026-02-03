//
//  WorkoutHistoryRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

@MainActor
protocol WorkoutHistoryRouter: GlobalRouter {
    func showDevSettingsView()
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate)
}

extension CoreRouter: WorkoutHistoryRouter { }

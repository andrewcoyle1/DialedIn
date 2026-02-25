//
//  ExerciseFrequencyRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ExerciseFrequencyRouter {
    func showDevSettingsView()
    func showActivityView(delegate: ActivityDelegate)
}

extension CoreRouter: ExerciseFrequencyRouter { }

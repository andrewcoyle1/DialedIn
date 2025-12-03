//
//  CreateExerciseRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

@MainActor
protocol CreateExerciseRouter {
    func showDevSettingsView()
    func showSimpleAlert(title: String, subtitle: String?)
    func dismissScreen()
}

extension CoreRouter: CreateExerciseRouter { }

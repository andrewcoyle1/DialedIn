//
//  CreateWorkoutRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol CreateWorkoutRouter {
    func showDevSettingsView()
    func showAddExercisesView(delegate: AddExerciseModalDelegate)
    func dismissScreen()
    func showAlert(error: Error)
}

extension CoreRouter: CreateWorkoutRouter { }

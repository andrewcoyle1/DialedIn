//
//  ExercisePickerRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ExercisePickerRouter {
    func showDevSettingsView()
    func dismissScreen()
}

extension CoreRouter: ExercisePickerRouter { }

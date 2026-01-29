//
//  AddExerciseModalRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol AddExerciseModalRouter {
    func showDevSettingsView()
    func dismissScreen()
}

extension CoreRouter: AddExerciseModalRouter { }

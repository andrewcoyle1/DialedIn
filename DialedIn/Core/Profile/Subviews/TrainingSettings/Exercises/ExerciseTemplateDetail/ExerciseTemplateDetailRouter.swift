//
//  ExerciseModelDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

@MainActor
protocol ExerciseModelDetailRouter {
    func showDevSettingsView()
    func dismissScreen()
    
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: ExerciseModelDetailRouter { }

//
//  ExerciseTemplateDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

@MainActor
protocol ExerciseTemplateDetailRouter {
    func showDevSettingsView()
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: ExerciseTemplateDetailRouter { }

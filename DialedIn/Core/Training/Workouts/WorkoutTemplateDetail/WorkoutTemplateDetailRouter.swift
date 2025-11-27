//
//  WorkoutTemplateDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WorkoutTemplateDetailRouter {
    func showDevSettingsView()
    func showWorkoutStartView(delegate: WorkoutStartDelegate)
    func showCreateWorkoutView(delegate: CreateWorkoutDelegate)

    func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: WorkoutTemplateDetailRouter { }

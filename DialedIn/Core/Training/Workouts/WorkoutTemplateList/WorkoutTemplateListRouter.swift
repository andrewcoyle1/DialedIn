//
//  WorkoutTemplateListRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WorkoutTemplateListRouter {
    func showDevSettingsView()
    func showCreateWorkoutView(delegate: CreateWorkoutDelegate)
    func showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate)
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: WorkoutTemplateListRouter { }

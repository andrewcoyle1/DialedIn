//
//  WorkoutTemplateDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol WorkoutTemplateDetailRouter {
    func showDevSettingsView()
    func showWorkoutStartView(delegate: WorkoutStartDelegate)
    func showCreateWorkoutView(delegate: CreateWorkoutDelegate)

    func showAlert(title: String, subtitle: String?, buttons: @escaping @Sendable () -> AnyView)
    func showSimpleAlert(title: String, subtitle: String?)

    func dismissScreen()
}

extension CoreRouter: WorkoutTemplateDetailRouter { }

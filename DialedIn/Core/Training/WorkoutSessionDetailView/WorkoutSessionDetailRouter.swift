//
//  WorkoutSessionDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

import SwiftUI

@MainActor
protocol WorkoutSessionDetailRouter {
    func showDevSettingsView()
    func showAddExercisesView(delegate: AddExerciseModalDelegate)

    func dismissScreen()

    func showSimpleAlert(title: String, subtitle: String?)
    func showAlert(title: String, subtitle: String?, buttons: @escaping @Sendable () -> AnyView)
}

extension CoreRouter: WorkoutSessionDetailRouter { }

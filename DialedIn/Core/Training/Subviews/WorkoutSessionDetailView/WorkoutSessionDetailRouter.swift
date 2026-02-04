//
//  WorkoutSessionDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

import SwiftUI

@MainActor
protocol WorkoutSessionDetailRouter: GlobalRouter {
    func showDevSettingsView()
    func showExercisePickerView(delegate: ExercisePickerDelegate)
}

extension CoreRouter: WorkoutSessionDetailRouter { }

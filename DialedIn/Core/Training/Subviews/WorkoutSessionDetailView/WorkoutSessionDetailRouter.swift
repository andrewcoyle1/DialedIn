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
    func showExercisesPickerView(delegate: ExercisesPickerDelegate)
}

extension CoreRouter: WorkoutSessionDetailRouter { }

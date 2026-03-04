//
//  WorkoutSessionDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

import SwiftUI

@MainActor
protocol WorkoutSessionDetailRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showExercisesPickerView(delegate: ExercisesPickerDelegate)
}

extension CoreRouter: WorkoutSessionDetailRouter { }

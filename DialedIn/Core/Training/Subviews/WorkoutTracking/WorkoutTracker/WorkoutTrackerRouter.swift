//
//  WorkoutTrackerRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 09/12/2025.
//

import SwiftUI

@MainActor
protocol WorkoutTrackerRouter: GlobalRouter {
    func showExercisesPickerView(delegate: ExercisesPickerDelegate)
    func showWorkoutNotesView(delegate: WorkoutNotesDelegate)
    func showWorkoutSettingsView(delegate: WorkoutSettingsDelegate)
    func showGymProfileView(delegate: GymProfileDelegate)
}

extension CoreRouter: WorkoutTrackerRouter { }

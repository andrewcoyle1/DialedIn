//
//  TrainingRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
protocol TrainingRouter: GlobalRouter {
    func showDevSettingsView()
    func showWorkoutStartModal(delegate: WorkoutStartDelegate)
    func showProgramManagementView()
    func showWorkoutsView()
    func showWorkoutHistoryView()
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate)
    func showWorkoutTrackerView(delegate: WorkoutTrackerDelegate)
    func showAddTrainingView(delegate: AddTrainingDelegate, onDismiss: (() -> Void)?)
    func showCreateProgramView(delegate: CreateProgramDelegate)
    func showCreateWorkoutView(delegate: CreateWorkoutDelegate)
    func showCreateExerciseView()
    func showProfileView()
    func showEditTrainingProgramView(delegate: EditTrainingProgramDelegate)

}

extension CoreRouter: TrainingRouter {
}

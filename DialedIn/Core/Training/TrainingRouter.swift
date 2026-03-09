//
//  TrainingRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol TrainingRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showWorkoutStartModal(delegate: WorkoutStartDelegate)
    func showProgramManagementView()
    func showWorkoutsView(delegate: WorkoutsDelegate)
    func showWorkoutHistoryView()
    func showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate)
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate)
    func showWorkoutTrackerView()
    func showAddTrainingView(delegate: AddTrainingDelegate, onDismiss: (() -> Void)?)
    func showCreateProgramView(delegate: CreateProgramDelegate)
    func showCreateWorkoutView(delegate: CreateWorkoutDelegate)
    func showCreateExerciseView()
    func showProfileView()
    func showEditTrainingProgramView(delegate: EditTrainingProgramDelegate)
}

extension CoreRouter: TrainingRouter { }

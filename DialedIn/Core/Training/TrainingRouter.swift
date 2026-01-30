//
//  TrainingRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol TrainingRouter: GlobalRouter {
    func showDevSettingsView()
    func showWorkoutStartView(delegate: WorkoutStartDelegate)
    func showProgramManagementView()
    func showProgressDashboardView()
    func showStrengthProgressView()
    func showWorkoutHeatmapView()
    func showWorkoutsView()
    func showWorkoutHistoryView()
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate)
    func showAddGoalView(delegate: AddGoalDelegate)
    func showWorkoutTrackerView(delegate: WorkoutTrackerDelegate)
    func showAddTrainingView(delegate: AddTrainingDelegate, onDismiss: (() -> Void)?)
    func showCreateProgramView(delegate: CreateProgramDelegate)
    func showCreateWorkoutView(delegate: CreateWorkoutDelegate)
    func showCreateExerciseView()
    func showGymProfilesView()
    func showProfileView()

}

extension CoreRouter: TrainingRouter {
}

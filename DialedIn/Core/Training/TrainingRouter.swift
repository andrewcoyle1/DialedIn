//
//  TrainingRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol TrainingRouter {
    func showNotificationsView()
    func showDevSettingsView()
    func showWorkoutStartView(delegate: WorkoutStartDelegate)
    func showProgramManagementView()
    func showProgressDashboardView()
    func showStrengthProgressView()
    func showWorkoutHeatmapView()
    
    func showWorkoutsView()
    func showExercisesView()
    func showWorkoutHistoryView()
    
    func showAlert(error: Error)
}

extension CoreRouter: TrainingRouter { }

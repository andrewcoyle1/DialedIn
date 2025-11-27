//
//  ProgramRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol ProgramRouter {
    func showWorkoutStartView(delegate: WorkoutStartDelegate)
    func showProgramManagementView()
    func showProgressDashboardView()
    func showStrengthProgressView()
    func showWorkoutHeatmapView()
    func showAddGoalView(delegate: AddGoalDelegate)

    func showAlert(error: Error)
}

extension CoreRouter: ProgramRouter { }

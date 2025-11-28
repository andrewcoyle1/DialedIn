//
//  WorkoutStartRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WorkoutStartRouter {
    func showWorkoutTrackerView(delegate: WorkoutTrackerDelegate)
    func dismissScreen()
}

extension CoreRouter: WorkoutStartRouter { }

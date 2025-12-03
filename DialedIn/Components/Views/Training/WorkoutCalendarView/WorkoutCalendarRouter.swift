//
//  WorkoutCalendarRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WorkoutCalendarRouter {
    func showWorkoutStartView(delegate: WorkoutStartDelegate)
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate)
    
    func showAlert(error: Error)
}

extension CoreRouter: WorkoutCalendarRouter { }

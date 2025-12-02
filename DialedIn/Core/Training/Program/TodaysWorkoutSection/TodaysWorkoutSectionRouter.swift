//
//  TodaysWorkoutSectionRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

@MainActor
protocol TodaysWorkoutSectionRouter {
    func showWorkoutStartView(delegate: WorkoutStartDelegate)
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate)
    
    func showAlert(error: Error)
}

extension CoreRouter: TodaysWorkoutSectionRouter { }

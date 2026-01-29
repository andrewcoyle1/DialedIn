//
//  WorkoutsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WorkoutsRouter {
    func showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate)
}

extension CoreRouter: WorkoutsRouter { }

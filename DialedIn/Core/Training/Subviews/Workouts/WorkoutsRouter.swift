//
//  WorkoutsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WorkoutsRouter: GlobalRouter {
    func showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate)
}

extension CoreRouter: WorkoutsRouter { }

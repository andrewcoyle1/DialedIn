//
//  ExercisesRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

@MainActor
protocol ExercisesRouter: GlobalRouter {
    func showCreateExerciseView()
    func showExerciseTemplateDetailView(delegate: ExerciseTemplateDetailDelegate)
    
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: ExercisesRouter { }

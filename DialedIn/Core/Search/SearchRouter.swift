//
//  SearchRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/01/2026.
//

import SwiftUI

@MainActor
protocol SearchRouter {
    func showProfileViewZoom(transitionId: String?, namespace: Namespace.ID)
    func showExerciseDetailView(templateId: String, name: String, delegate: ExerciseDetailDelegate)
    func showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate)
    func showRecipeDetailView(delegate: RecipeDetailDelegate)
    func showWorkoutStartModal(delegate: WorkoutStartDelegate)
    func showRecipesView()
    func showWorkoutPickerView(delegate: WorkoutPickerDelegate)
    func showExerciseListBuilderView(delegate: ExerciseListBuilderDelegate)
    func showWorkoutTrackerView(delegate: WorkoutTrackerDelegate)
    func showSimpleAlert(title: String, subtitle: String?)
    func dismissModal()
    func dismissEnvironment()
}

extension CoreRouter: SearchRouter { }

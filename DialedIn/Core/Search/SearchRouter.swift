//
//  SearchRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/01/2026.
//

import SwiftUI

@MainActor
protocol SearchRouter: GlobalRouter {
    func showProfileViewZoom(transitionId: String?, namespace: Namespace.ID)
    func showExerciseDetailView(templateId: String, name: String, delegate: ExerciseDetailDelegate, themeColor: Color?)
    func showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate)
    func showRecipeDetailView(delegate: RecipeDetailDelegate)
    func showFoodDetailView(delegate: FoodDetailDelegate)
    func showRecipesView()
    func showAddMealView(delegate: AddMealDelegate)
    func showWorkoutsView(delegate: WorkoutsDelegate)
    func showCreateExerciseView()
    func showExerciseListBuilderView(delegate: ExerciseListBuilderDelegate)
    func showWorkoutTrackerView()
    func showLogWeightView()
}

extension CoreRouter: SearchRouter { }

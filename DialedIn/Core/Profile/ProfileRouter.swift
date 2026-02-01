//
//  ProfileRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProfileRouter: GlobalRouter {
    func showAccountView(delegate: AccountDelegate)
    func showPhysicalStatsView()
    func showProfileGoalsView()
    func showProfileNutritionDetailView()
    func showSettingsView()
    func showNotificationsView()
    func showExercisesView()
    func showExerciseTemplateListView(delegate: ExerciseTemplateListDelegate)
    func showWorkoutTemplateListView()
    func showIngredientTemplateListView(delegate: IngredientTemplateListDelegate)
    func showRecipeTemplateListView(delegate: RecipeTemplateListDelegate)
    func showWorkoutSettingsView(delegate: WorkoutSettingsDelegate)
    func showGymProfilesView()
    func showTutorialsView(delegate: TutorialsDelegate)
    func showAboutView(delegate: AboutDelegate)
}

extension CoreRouter: ProfileRouter { }

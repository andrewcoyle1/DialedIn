//
//  ProfileMyTemplatesRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProfileMyTemplatesRouter {
    func showDevSettingsView()
    func showExerciseTemplateListView(delegate: ExerciseTemplateListDelegate)
    func showWorkoutTemplateListView()
    func showIngredientTemplateListView(delegate: IngredientTemplateListDelegate)
    func showRecipeTemplateListView(delegate: RecipeTemplateListDelegate)
}

extension CoreRouter: ProfileMyTemplatesRouter { }

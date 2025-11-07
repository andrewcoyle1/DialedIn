//
//  TabBarPathOption.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/12/24.
//

import Foundation

enum TabBarPathOption: Hashable, Sendable {
    case exerciseTemplate(exerciseTemplate: ExerciseTemplateModel)
    case workoutTemplateList
    case workoutTemplateDetail(template: WorkoutTemplateModel)
    case ingredientTemplateDetail(template: IngredientTemplateModel)
    case recipeTemplateDetail(template: RecipeTemplateModel)
    case workoutSessionDetail(session: WorkoutSessionModel)
    case mealDetail(meal: MealLogModel)
}

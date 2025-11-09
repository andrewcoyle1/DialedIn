//
//  TabBarPathOption.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/12/24.
//

import Foundation

enum TabBarPathOption: Hashable, Sendable {
    case exerciseTemplate(exerciseTemplate: ExerciseTemplateModel)
    case exerciseTemplateList(templateIds: [String])
    case workoutTemplateList(templateIds: [String])
    case workoutTemplateDetail(template: WorkoutTemplateModel)
    case ingredientTemplateDetail(template: IngredientTemplateModel)
    case ingredientTemplateList(templateIds: [String])
    case ingredientAmountView(ingredient: IngredientTemplateModel, onPick: (MealItemModel) -> Void)
    case recipeTemplateDetail(template: RecipeTemplateModel)
    case recipeTemplateList(templateIds: [String])
    case recipeAmountView(recipe: RecipeTemplateModel, onPick: (MealItemModel) -> Void)
    case workoutSessionDetail(session: WorkoutSessionModel)
    case mealDetail(meal: MealLogModel)
    case profileGoals
    case profileEdit
    case profileNutritionDetail
    case profilePhysicalStats
    case settingsView
    case manageSubscription
    case programPreview(template: ProgramTemplateModel, startDate: Date)
    case customProgramBuilderView
    case programGoalsView(plan: TrainingPlan)
    case programScheduleView(plan: TrainingPlan)

    var description: String {
        switch self {
        case .exerciseTemplate:         return "ExerciseTemplates"
        case .exerciseTemplateList:     return "ExerciseTemplateList"
        case .workoutTemplateList:      return "WorkoutTemplateList"
        case .workoutTemplateDetail:    return "WorkoutTemplateDetail"
        case .ingredientTemplateDetail: return "IngredientTemplateDetail"
        case .ingredientTemplateList:   return "IngredientTemplateList"
        case .ingredientAmountView:     return "IngredientAmount"
        case .recipeTemplateDetail:     return "RecipeTemplateDetail"
        case .recipeTemplateList:       return "RecipeTemplateList"
        case .recipeAmountView:         return "RecipeAmount"
        case .workoutSessionDetail:     return "WorkoutSessionDetail"
        case .mealDetail:               return "MealDetail"
        case .profileGoals:             return "ProfileGoalsView"
        case .profileEdit:              return "ProfileEditView"
        case .profileNutritionDetail:   return "ProfileNutritionDetail"
        case .profilePhysicalStats:     return "ProfilePhysicalStats"
        case .settingsView:             return "SettingsView"
        case .manageSubscription:       return "ManageSubscriptionView"
        case .programPreview:           return "ProgramPreviewView"
        case .customProgramBuilderView: return "ProgramBuilderView"
        case .programGoalsView:         return "ProgramGoalsView"
        case .programScheduleView:      return "ProgramScheduleView"
        }
    }

    var eventParameters: [String: Any] {
        let params: [String: Any]  = [
            "destination": self
        ]

        return params
    }
}

extension TabBarPathOption {
    static func == (lhs: TabBarPathOption, rhs: TabBarPathOption) -> Bool {
        switch (lhs, rhs) {
        case (.exerciseTemplate(let lhs), .exerciseTemplate(let rhs)):
            return lhs.exerciseId == rhs.exerciseId
        case (.workoutTemplateList, .workoutTemplateList):
            return true
        case (.workoutTemplateDetail(let lhs), .workoutTemplateDetail(let rhs)):
            return lhs.workoutId == rhs.workoutId
        case (.ingredientTemplateDetail(let lhs), .ingredientTemplateDetail(let rhs)):
            return lhs.ingredientId == rhs.ingredientId
        case (.ingredientAmountView(let lhs, _), .ingredientAmountView(let rhs, _)):
            return lhs.ingredientId == rhs.ingredientId
        case (.recipeTemplateDetail(let lhs), .recipeTemplateDetail(let rhs)):
            return lhs.recipeId == rhs.recipeId
        case (.recipeAmountView(let lhs, _), .recipeAmountView(let rhs, _)):
            return lhs.recipeId == rhs.recipeId
        case (.workoutSessionDetail(let lhs), .workoutSessionDetail(let rhs)):
            return lhs.id == rhs.id
        case (.mealDetail(let lhs), .mealDetail(let rhs)):
            return lhs.mealId == rhs.mealId
        default:
            return false
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func hash(into hasher: inout Hasher) {
        switch self {
        case .exerciseTemplate(let exerciseTemplate):
            hasher.combine(0)
            hasher.combine(exerciseTemplate.exerciseId)
        case .exerciseTemplateList(templateIds: let templateIds):
            hasher.combine(1)
            hasher.combine(templateIds)
        case .workoutTemplateList:
            hasher.combine(2)
        case .workoutTemplateDetail(let template):
            hasher.combine(3)
            hasher.combine(template.workoutId)
        case .ingredientTemplateDetail(let template):
            hasher.combine(4)
            hasher.combine(template.ingredientId)
        case .ingredientTemplateList(templateIds: let templateIds):
            hasher.combine(5)
            hasher.combine(templateIds)
        case .ingredientAmountView(let ingredient, _):
            hasher.combine(6)
            hasher.combine(ingredient.ingredientId)
        case .recipeTemplateDetail(let template):
            hasher.combine(7)
            hasher.combine(template.recipeId)
        case .recipeTemplateList(templateIds: let templateIds):
            hasher.combine(8)
            hasher.combine(templateIds)
        case .recipeAmountView(let recipe, _):
            hasher.combine(9)
            hasher.combine(recipe.recipeId)
        case .workoutSessionDetail(let session):
            hasher.combine(10)
            hasher.combine(session.id)
        case .mealDetail(let meal):
            hasher.combine(11)
            hasher.combine(meal.mealId)
        case .profileGoals:
            hasher.combine(12)
        case .profileEdit:
            hasher.combine(13)
        case .profileNutritionDetail:
            hasher.combine(14)
        case .profilePhysicalStats:
            hasher.combine(15)
        case .settingsView:
            hasher.combine(16)
        case .manageSubscription:
            hasher.combine(17)
        case .programPreview(template: let template, startDate: let startDate):
            hasher.combine(18)
            hasher.combine(template.id)
            hasher.combine(startDate.timeIntervalSince1970)
        case .customProgramBuilderView:
            hasher.combine(19)
        case .programGoalsView(plan: let plan):
            hasher.combine(20)
            hasher.combine(plan.id)
        case .programScheduleView(plan: let plan):
            hasher.combine(21)
            hasher.combine(plan.id)
        }
    }
}

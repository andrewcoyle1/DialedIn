//
//  NavDestinationForTabBarViewModifier.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

struct NavDestinationForTabBarViewModifier: ViewModifier {

    @Environment(CoreBuilder.self) private var builder
    let path: Binding<[TabBarPathOption]>
    
    // swiftlint:disable:next cyclomatic_complexity
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: TabBarPathOption.self) { newValue in
                switch newValue {
                case .exerciseTemplate(exerciseTemplate: let exerciseTemplate):
                    builder.exerciseTemplateDetailView(delegate: ExerciseTemplateDetailViewDelegate(exerciseTemplate: exerciseTemplate))
                case .exerciseTemplateList(templateIds: let templateIds):
                    builder.exerciseTemplateListView(delegate: ExerciseTemplateListViewDelegate(templateIds: templateIds))
                case .workoutTemplateList(templateIds: let templateIds):
                    builder.workoutTemplateListView(delegate: WorkoutTemplateListViewDelegate(templateIds: templateIds))
                case .workoutTemplateDetail(template: let template):
                    builder.workoutTemplateDetailView(delegate: WorkoutTemplateDetailViewDelegate(workoutTemplate: template))
                case .ingredientTemplateDetail(template: let template):
                    builder.ingredientDetailView(delegate: IngredientDetailViewDelegate(ingredientTemplate: template))
                case .ingredientTemplateList(templateIds: let templateIds):
                    builder.ingredientTemplateListView(delegate: IngredientTemplateListViewDelegate(templateIds: templateIds))
                case .ingredientAmountView(ingredient: let ingredient, onPick: let onPick):
                    builder.ingredientAmountView(delegate: IngredientAmountViewDelegate(ingredient: ingredient, onPick: onPick))
                case .recipeTemplateDetail(template: let template):
                    builder.recipeDetailView(delegate: RecipeDetailViewDelegate(recipeTemplate: template))
                case .recipeTemplateList(templateIds: let templateIds):
                    builder.recipeTemplateListView(delegate: RecipeTemplateListViewDelegate(templateIds: templateIds))
                case .recipeAmountView(recipe: let recipe, onPick: let onPick):
                    builder.recipeAmountView(recipe: recipe, onPick: onPick)
                case .workoutSessionDetail(session: let session):
                    builder.workoutSessionDetailView(delegate: WorkoutSessionDetailViewDelegate(workoutSession: session))
                case .mealDetail(meal: let meal):
                    builder.mealDetailView(delegate: MealDetailViewDelegate(meal: meal))
                case .profileGoals:
                    builder.profileGoalsDetailView()
                case .profileEdit:
                    builder.profileEditView()
                case .profileNutritionDetail:
                    builder.profileNutritionDetailView()
                case .profilePhysicalStats:
                    builder.profilePhysicalStatsView()
                case .settingsView:
                    builder.settingsView(delegate: SettingsViewDelegate(path: path))
                case .manageSubscription:
                    builder.manageSubscriptionView()
                case .programPreview(template: let template, startDate: let startDate):
                    builder.programPreviewView(template: template, startDate: startDate)
                case .customProgramBuilderView:
                    builder.customProgramBuilderView(delegate: CustomProgramBuilderViewDelegate(path: path))
                case .programGoalsView(plan: let plan):
                    builder.programGoalsView(delegate: ProgramGoalsViewDelegate(plan: plan))
                case .programScheduleView(plan: let plan):
                    builder.programScheduleView(delegate: ProgramScheduleViewDelegate(plan: plan))
                }
            }
    }
}

extension View {
    
    func navDestinationForTabBarModule(path: Binding<[TabBarPathOption]>) -> some View {
        modifier(NavDestinationForTabBarViewModifier(path: path))
    }
}

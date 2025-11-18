//
//  NavDestinationForTabBarViewModifier.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

struct NavDestinationForTabBarViewModifier: ViewModifier {

    let path: Binding<[TabBarPathOption]>

    @ViewBuilder var exerciseTemplateDetailView: (ExerciseTemplateDetailViewDelegate) -> AnyView
    @ViewBuilder var exerciseTemplateListView: (ExerciseTemplateListViewDelegate) -> AnyView
    @ViewBuilder var workoutTemplateListView: (WorkoutTemplateListViewDelegate) -> AnyView
    @ViewBuilder var workoutTemplateDetailView: (WorkoutTemplateDetailViewDelegate) -> AnyView
    @ViewBuilder var ingredientDetailView: (IngredientDetailViewDelegate) -> AnyView
    @ViewBuilder var ingredientTemplateListView: (IngredientTemplateListViewDelegate) -> AnyView
    @ViewBuilder var ingredientAmountView: (IngredientAmountViewDelegate) -> AnyView
    @ViewBuilder var recipeDetailView: (RecipeDetailViewDelegate) -> AnyView
    @ViewBuilder var recipeTemplateListView: (RecipeTemplateListViewDelegate) -> AnyView
    @ViewBuilder var recipeAmountView: (RecipeAmountViewDelegate) -> AnyView
    @ViewBuilder var workoutSessionDetailView: (WorkoutSessionDetailViewDelegate) -> AnyView
    @ViewBuilder var mealDetailView: (MealDetailViewDelegate) -> AnyView
    @ViewBuilder var profileGoalsDetailView: () -> AnyView
    @ViewBuilder var profileEditView: () -> AnyView
    @ViewBuilder var profileNutritionDetailView: () -> AnyView
    @ViewBuilder var profilePhysicalStatsView: () -> AnyView
    @ViewBuilder var settingsView: (SettingsViewDelegate) -> AnyView
    @ViewBuilder var manageSubscriptionView: () -> AnyView
    @ViewBuilder var programPreviewView: (ProgramPreviewViewDelegate) -> AnyView
    @ViewBuilder var customProgramBuilderView: (CustomProgramBuilderViewDelegate) -> AnyView
    @ViewBuilder var programGoalsView: (ProgramGoalsViewDelegate) -> AnyView
    @ViewBuilder var programScheduleView: (ProgramScheduleViewDelegate) -> AnyView

    // swiftlint:disable:next cyclomatic_complexity
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: TabBarPathOption.self) { newValue in
                switch newValue {
                case .exerciseTemplate(exerciseTemplate: let exerciseTemplate):
                    exerciseTemplateDetailView(ExerciseTemplateDetailViewDelegate(exerciseTemplate: exerciseTemplate))
                case .exerciseTemplateList(templateIds: let templateIds):
                    exerciseTemplateListView(ExerciseTemplateListViewDelegate(templateIds: templateIds))
                case .workoutTemplateList(templateIds: let templateIds):
                    workoutTemplateListView(WorkoutTemplateListViewDelegate(templateIds: templateIds))
                case .workoutTemplateDetail(template: let template):
                    workoutTemplateDetailView(WorkoutTemplateDetailViewDelegate(workoutTemplate: template))
                case .ingredientTemplateDetail(template: let template):
                    ingredientDetailView(IngredientDetailViewDelegate(ingredientTemplate: template))
                case .ingredientTemplateList(templateIds: let templateIds):
                    ingredientTemplateListView(IngredientTemplateListViewDelegate(templateIds: templateIds))
                case .ingredientAmountView(ingredient: let ingredient, onPick: let onPick):
                    ingredientAmountView(IngredientAmountViewDelegate(ingredient: ingredient, onPick: onPick))
                case .recipeTemplateDetail(template: let template):
                    recipeDetailView(RecipeDetailViewDelegate(recipeTemplate: template))
                case .recipeTemplateList(templateIds: let templateIds):
                    recipeTemplateListView(RecipeTemplateListViewDelegate(templateIds: templateIds))
                case .recipeAmountView(recipe: let recipe, onPick: let onPick):
                    recipeAmountView(RecipeAmountViewDelegate(recipe: recipe, onPick: onPick))
                case .workoutSessionDetail(session: let session):
                    workoutSessionDetailView(WorkoutSessionDetailViewDelegate(workoutSession: session))
                case .mealDetail(meal: let meal):
                    mealDetailView(MealDetailViewDelegate(meal: meal))
                case .profileGoals:
                    profileGoalsDetailView()
                case .profileEdit:
                    profileEditView()
                case .profileNutritionDetail:
                    profileNutritionDetailView()
                case .profilePhysicalStats:
                    profilePhysicalStatsView()
                case .settingsView:
                    settingsView(SettingsViewDelegate(path: path))
                case .manageSubscription:
                    manageSubscriptionView()
                case .programPreview(template: let template, startDate: let startDate):
                    programPreviewView(ProgramPreviewViewDelegate(template: template, startDate: startDate))
                case .customProgramBuilderView:
                    customProgramBuilderView(CustomProgramBuilderViewDelegate(path: path))
                case .programGoalsView(plan: let plan):
                    programGoalsView(ProgramGoalsViewDelegate(plan: plan))
                case .programScheduleView(plan: let plan):
                    programScheduleView(ProgramScheduleViewDelegate(plan: plan))
                }
            }
    }
}

extension View {

    // swiftlint:disable:next function_parameter_count
    func navDestinationForTabBarModule(
        path: Binding<[TabBarPathOption]>,
        @ViewBuilder exerciseTemplateDetailView: @escaping (ExerciseTemplateDetailViewDelegate) -> AnyView,
        @ViewBuilder exerciseTemplateListView: @escaping (ExerciseTemplateListViewDelegate) -> AnyView,
        @ViewBuilder workoutTemplateListView: @escaping (WorkoutTemplateListViewDelegate) -> AnyView,
        @ViewBuilder workoutTemplateDetailView: @escaping (WorkoutTemplateDetailViewDelegate) -> AnyView,
        @ViewBuilder ingredientDetailView: @escaping (IngredientDetailViewDelegate) -> AnyView,
        @ViewBuilder ingredientTemplateListView: @escaping (IngredientTemplateListViewDelegate) -> AnyView,
        @ViewBuilder ingredientAmountView: @escaping (IngredientAmountViewDelegate) -> AnyView,
        @ViewBuilder recipeDetailView: @escaping (RecipeDetailViewDelegate) -> AnyView,
        @ViewBuilder recipeTemplateListView: @escaping (RecipeTemplateListViewDelegate) -> AnyView,
        @ViewBuilder recipeAmountView: @escaping (RecipeAmountViewDelegate) -> AnyView,
        @ViewBuilder workoutSessionDetailView: @escaping (WorkoutSessionDetailViewDelegate) -> AnyView,
        @ViewBuilder mealDetailView: @escaping (MealDetailViewDelegate) -> AnyView,
        @ViewBuilder profileGoalsDetailView: @escaping () -> AnyView,
        @ViewBuilder profileEditView: @escaping () -> AnyView,
        @ViewBuilder profileNutritionDetailView: @escaping () -> AnyView,
        @ViewBuilder profilePhysicalStatsView: @escaping () -> AnyView,
        @ViewBuilder settingsView: @escaping (SettingsViewDelegate) -> AnyView,
        @ViewBuilder manageSubscriptionView: @escaping () -> AnyView,
        @ViewBuilder programPreviewView: @escaping (ProgramPreviewViewDelegate) -> AnyView,
        @ViewBuilder customProgramBuilderView: @escaping (CustomProgramBuilderViewDelegate) -> AnyView,
        @ViewBuilder programGoalsView: @escaping (ProgramGoalsViewDelegate) -> AnyView,
        @ViewBuilder programScheduleView: @escaping (ProgramScheduleViewDelegate) -> AnyView
    ) -> some View {
        modifier(
            NavDestinationForTabBarViewModifier(
                path: path,
                exerciseTemplateDetailView: exerciseTemplateDetailView,
                exerciseTemplateListView: exerciseTemplateListView,
                workoutTemplateListView: workoutTemplateListView,
                workoutTemplateDetailView: workoutTemplateDetailView,
                ingredientDetailView: ingredientDetailView,
                ingredientTemplateListView: ingredientTemplateListView,
                ingredientAmountView: ingredientAmountView,
                recipeDetailView: recipeDetailView,
                recipeTemplateListView: recipeTemplateListView,
                recipeAmountView: recipeAmountView,
                workoutSessionDetailView: workoutSessionDetailView,
                mealDetailView: mealDetailView,
                profileGoalsDetailView: profileGoalsDetailView,
                profileEditView: profileEditView,
                profileNutritionDetailView: profileNutritionDetailView,
                profilePhysicalStatsView: profilePhysicalStatsView,
                settingsView: settingsView,
                manageSubscriptionView: manageSubscriptionView,
                programPreviewView: programPreviewView,
                customProgramBuilderView: customProgramBuilderView,
                programGoalsView: programGoalsView,
                programScheduleView: programScheduleView
            )
        )
    }
}

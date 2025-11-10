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
    
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: TabBarPathOption.self) { newValue in
                switch newValue {
                case .exerciseTemplate(exerciseTemplate: let exerciseTemplate):
                    builder.exerciseTemplateDetailView(exercise: exerciseTemplate)
                case .exerciseTemplateList(templateIds: let templateIds):
                    builder.exerciseTemplateListView(templateIds: templateIds)
                case .workoutTemplateList(templateIds: let templateIds):
                    builder.workoutTemplateListView(templateIds: templateIds)
                case .workoutTemplateDetail(template: let template):
                    builder.workoutTemplateDetailView(workout: template)
                case .ingredientTemplateDetail(template: let template):
                    builder.ingredientDetailView(ingredientTemplate: template)
                case .ingredientTemplateList(templateIds: let templateIds):
                    builder.ingredientTemplateListView(templateIds: templateIds)
                case .ingredientAmountView(ingredient: let ingredient, onPick: let onPick):
                    builder.ingredientAmountView(ingredient: ingredient, onPick: onPick)
                case .recipeTemplateDetail(template: let template):
                    builder.recipeDetailView(recipeTemplate: template)
                case .recipeTemplateList(templateIds: let templateIds):
                    builder.recipeTemplateListView(templateIds: templateIds)
                case .recipeAmountView(recipe: let recipe, onPick: let onPick):
                    builder.recipeAmountView(recipe: recipe, onPick: onPick)
                case .workoutSessionDetail(session: let session):
                    builder.workoutSessionDetailView(session: session)
                case .mealDetail(meal: let meal):
                    builder.mealDetailView(meal: meal)
                case .profileGoals:
                    builder.profileGoalsDetailView()
                case .profileEdit:
                    builder.profileEditView()
                case .profileNutritionDetail:
                    builder.profileNutritionDetailView()
                case .profilePhysicalStats:
                    builder.profilePhysicalStatsView()
                case .settingsView:
                    builder.settingsView(path: path)
                case .manageSubscription:
                    builder.manageSubscriptionView()
                case .programPreview(template: let template, startDate: let startDate):
                    builder.programPreviewView(template: template, startDate: startDate)
                case .customProgramBuilderView:
                    builder.customProgramBuilderView(path: path)
                case .programGoalsView(plan: let plan):
                    builder.programGoalsView(plan: plan)
                case .programScheduleView(plan: let plan):
                    builder.programScheduleView(plan: plan)
                }
            }
    }
}

extension View {
    
    func navDestinationForTabBarModule(path: Binding<[TabBarPathOption]>) -> some View {
        modifier(NavDestinationForTabBarViewModifier(path: path))
    }
}

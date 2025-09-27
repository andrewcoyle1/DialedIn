//
//  NavigationPathOption.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/12/24.
//
import SwiftUI
import Foundation

enum NavigationPathOption: Hashable {
    case exerciseTemplate(exerciseTemplate: ExerciseTemplateModel)
    case workoutTemplateList
    case workoutTemplateDetail(template: WorkoutTemplateModel)
    case ingredientTemplateDetail(template: IngredientTemplateModel)
    case recipeTemplateDetail(template: RecipeTemplateModel)
}

extension View {
    
    func navigationDestinationForCoreModule(path: Binding<[NavigationPathOption]>) -> some View {
        self
            .navigationDestination(for: NavigationPathOption.self) { newValue in
                switch newValue {
                case .exerciseTemplate(exerciseTemplate: let exerciseTemplate):
                    ExerciseDetailView(exerciseTemplate: exerciseTemplate)
                case .workoutTemplateList:
                    WorkoutTemplateListView()
                case .workoutTemplateDetail(template: let template):
                    WorkoutTemplateDetailView(workoutTemplate: template)
                case .ingredientTemplateDetail(template: let template):
                    IngredientDetailView(ingredientTemplate: template)
                case .recipeTemplateDetail(template: let template):
                    RecipeDetailView(recipeTemplate: template)
                }
            }
    }
}

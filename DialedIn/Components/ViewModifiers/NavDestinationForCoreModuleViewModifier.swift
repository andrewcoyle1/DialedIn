//
//  NavDestinationForCoreModuleViewModifier.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

struct NavDestinationForCoreModuleViewModifier: ViewModifier {
    
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[NavigationPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationPathOption.self) { newValue in
                switch newValue {
                case .exerciseTemplate(exerciseTemplate: let exerciseTemplate):
                    ExerciseTemplateDetailView(viewModel: ExerciseTemplateDetailViewModel(interactor: CoreInteractor(container: container)), exerciseTemplate: exerciseTemplate)
                case .workoutTemplateList:
                    WorkoutTemplateListView(interactor: CoreInteractor(container: container), templateIds: nil)
                case .workoutTemplateDetail(template: let template):
                    WorkoutTemplateDetailView(viewModel: WorkoutTemplateDetailViewModel(interactor: CoreInteractor(container: container)), workoutTemplate: template)
                case .ingredientTemplateDetail(template: let template):
                    IngredientDetailView(viewModel: IngredientDetailViewModel(interactor: CoreInteractor(container: container), ingredientTemplate: template))
                case .recipeTemplateDetail(template: let template):
                    RecipeDetailView(viewModel: RecipeDetailViewModel(interactor: CoreInteractor(container: container), recipeTemplate: template))
                case .workoutSessionDetail(session: let session):
                    WorkoutSessionDetailView(viewModel: WorkoutSessionDetailViewModel(interactor: CoreInteractor(container: container), session: session))
                case .mealDetail(meal: let meal):
                    MealDetailView(
                        viewModel: MealDetailViewModel(
                            interactor: CoreInteractor(container: container),
                            meal: meal
                        )
                    )
                }
            }
    }
}

extension View {
    
    func navigationDestinationForCoreModule(path: Binding<[NavigationPathOption]>) -> some View {
        modifier(NavDestinationForCoreModuleViewModifier(path: path))
    }
}

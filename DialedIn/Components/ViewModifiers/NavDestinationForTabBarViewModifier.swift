//
//  NavDestinationForTabBarViewModifier.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

struct NavDestinationForTabBarViewModifier: ViewModifier {
    
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[TabBarPathOption]>
    
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: TabBarPathOption.self) { newValue in
                switch newValue {
                case .exerciseTemplate(exerciseTemplate: let exerciseTemplate):
                    ExerciseTemplateDetailView(
                        viewModel: ExerciseTemplateDetailViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ),
                        exerciseTemplate: exerciseTemplate
                    )
                case .exerciseTemplateList(templateIds: let templateIds):
                    ExerciseTemplateListView(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        templateIds: templateIds
                    )
                case .workoutTemplateList(templateIds: let templateIds):
                    WorkoutTemplateListView(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        templateIds: templateIds
                    )
                case .workoutTemplateDetail(template: let template):
                    WorkoutTemplateDetailView(
                        viewModel: WorkoutTemplateDetailViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ),
                        workoutTemplate: template
                    )
                case .ingredientTemplateDetail(template: let template):
                    IngredientDetailView(
                        viewModel: IngredientDetailViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            ingredientTemplate: template
                        )
                    )
                case .ingredientTemplateList(templateIds: let templateIds):
                    IngredientTemplateListView(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        templateIds: templateIds
                    )
                case .ingredientAmountView(ingredient: let ingredient, onPick: let onPick):
                    IngredientAmountView(
                        viewModel: IngredientAmountViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            ingredient: ingredient,
                            onConfirm: onPick
                        )
                    )
                case .recipeTemplateDetail(template: let template):
                    RecipeDetailView(
                        viewModel: RecipeDetailViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            recipeTemplate: template
                        )
                    )
                case .recipeTemplateList(templateIds: let templateIds):
                    RecipeTemplateListView(interactor: CoreInteractor(container: container), templateIds: templateIds)
                case .recipeAmountView(recipe: let recipe, onPick: let onPick):
                    RecipeAmountView(
                        viewModel: RecipeAmountViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            recipe: recipe,
                            onConfirm: onPick
                        )
                    )
                case .workoutSessionDetail(session: let session):
                    WorkoutSessionDetailView(
                        viewModel: WorkoutSessionDetailViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            session: session
                        )
                    )
                case .mealDetail(meal: let meal):
                    MealDetailView(
                        viewModel: MealDetailViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            meal: meal
                        )
                    )
                case .profileGoals:
                    ProfileGoalsDetailView(viewModel: ProfileGoalsDetailViewModel(interactor: CoreInteractor(container: container)))
                case .profileEdit:
                    ProfileEditView(viewModel: ProfileEditViewModel(interactor: CoreInteractor(container: container)))
                case .profileNutritionDetail:
                    ProfileNutritionDetailView(
                        viewModel: ProfileNutritionDetailViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        )
                    )
                case .profilePhysicalStats:
                    ProfilePhysicalStatsView(
                        viewModel: ProfilePhysicalStatsViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        )
                    )
                case .settingsView:
                    SettingsView(
                        viewModel: SettingsViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ),
                        path: path
                    )
                case .manageSubscription:
                    ManageSubscriptionView()
                case .programPreview(template: let template, startDate: let startDate):
                    ProgramPreviewView(
                        viewModel: ProgramPreviewViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ),
                        template: template,
                        startDate: startDate
                    )
                case .customProgramBuilderView:
                    CustomProgramBuilderView(
                        viewModel: CustomProgramBuilderViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ),
                        path: path
                    )
                case .programGoalsView(plan: let plan):
                    ProgramGoalsView(viewModel: ProgramGoalsViewModel(interactor: CoreInteractor(container: container), plan: plan))
                case .programScheduleView(plan: let plan):
                    ProgramScheduleView(viewModel: ProgramScheduleViewModel(interactor: CoreInteractor(container: container)), plan: plan)
                }
            }
    }
}

extension View {
    
    func navDestinationForTabBarModule(path: Binding<[TabBarPathOption]>) -> some View {
        modifier(NavDestinationForTabBarViewModifier(path: path))
    }
}

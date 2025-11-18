//
//  GenericTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

struct GenericTemplateListView<Template: TemplateModel>: View {

    @Environment(\.dismiss) private var dismiss

    @State var viewModel: GenericTemplateListViewModel<Template>
    let configuration: TemplateListConfiguration<Template>
    let supportsRefresh: Bool
    let templateIdsOverride: [String]?

    let exerciseTemplateDetailView: (ExerciseTemplateDetailViewDelegate) -> AnyView
    let exerciseTemplateListView: (ExerciseTemplateListViewDelegate) -> AnyView
    let workoutTemplateListView: (WorkoutTemplateListViewDelegate) -> AnyView
    let workoutTemplateDetailView: (WorkoutTemplateDetailViewDelegate) -> AnyView
    let ingredientDetailView: (IngredientDetailViewDelegate) -> AnyView
    let ingredientTemplateListView: (IngredientTemplateListViewDelegate) -> AnyView
    let ingredientAmountView: (IngredientAmountViewDelegate) -> AnyView
    let recipeDetailView: (RecipeDetailViewDelegate) -> AnyView
    let recipeTemplateListView: (RecipeTemplateListViewDelegate) -> AnyView
    let recipeAmountView: (RecipeAmountViewDelegate) -> AnyView
    let workoutSessionDetailView: (WorkoutSessionDetailViewDelegate) -> AnyView
    let mealDetailView: (MealDetailViewDelegate) -> AnyView
    let profileGoalsDetailView: () -> AnyView
    let profileEditView: () -> AnyView
    let profileNutritionDetailView: () -> AnyView
    let profilePhysicalStatsView: () -> AnyView
    let settingsView: (SettingsViewDelegate) -> AnyView
    let manageSubscriptionView: () -> AnyView
    let programPreviewView: (ProgramPreviewViewDelegate) -> AnyView
    let customProgramBuilderView: (CustomProgramBuilderViewDelegate) -> AnyView
    let programGoalsView: (ProgramGoalsViewDelegate) -> AnyView
    let programScheduleView: (ProgramScheduleViewDelegate) -> AnyView

    init(
        viewModel: GenericTemplateListViewModel<Template>,
        configuration: TemplateListConfiguration<Template>,
        supportsRefresh: Bool = false,
        templateIdsOverride: [String]? = nil,
        exerciseTemplateDetailView: @escaping (ExerciseTemplateDetailViewDelegate) -> AnyView,
        exerciseTemplateListView: @escaping (ExerciseTemplateListViewDelegate) -> AnyView,
        workoutTemplateListView: @escaping (WorkoutTemplateListViewDelegate) -> AnyView,
        workoutTemplateDetailView: @escaping (WorkoutTemplateDetailViewDelegate) -> AnyView,
        ingredientDetailView: @escaping (IngredientDetailViewDelegate) -> AnyView,
        ingredientTemplateListView: @escaping (IngredientTemplateListViewDelegate) -> AnyView,
        ingredientAmountView: @escaping (IngredientAmountViewDelegate) -> AnyView,
        recipeDetailView: @escaping (RecipeDetailViewDelegate) -> AnyView,
        recipeTemplateListView: @escaping (RecipeTemplateListViewDelegate) -> AnyView,
        recipeAmountView: @escaping (RecipeAmountViewDelegate) -> AnyView,
        workoutSessionDetailView: @escaping (WorkoutSessionDetailViewDelegate) -> AnyView,
        mealDetailView: @escaping (MealDetailViewDelegate) -> AnyView,
        profileGoalsDetailView: @escaping () -> AnyView,
        profileEditView: @escaping () -> AnyView,
        profileNutritionDetailView: @escaping () -> AnyView,
        profilePhysicalStatsView: @escaping () -> AnyView,
        settingsView: @escaping (SettingsViewDelegate) -> AnyView,
        manageSubscriptionView: @escaping () -> AnyView,
        programPreviewView: @escaping (ProgramPreviewViewDelegate) -> AnyView,
        customProgramBuilderView: @escaping (CustomProgramBuilderViewDelegate) -> AnyView,
        programGoalsView: @escaping (ProgramGoalsViewDelegate) -> AnyView,
        programScheduleView: @escaping (ProgramScheduleViewDelegate) -> AnyView
    ) {
        self.viewModel = viewModel
        self.configuration = configuration
        self.supportsRefresh = supportsRefresh
        self.templateIdsOverride = templateIdsOverride
        self.exerciseTemplateDetailView = exerciseTemplateDetailView
        self.exerciseTemplateListView = exerciseTemplateListView
        self.workoutTemplateListView = workoutTemplateListView
        self.workoutTemplateDetailView = workoutTemplateDetailView
        self.ingredientDetailView = ingredientDetailView
        self.ingredientTemplateListView = ingredientTemplateListView
        self.ingredientAmountView = ingredientAmountView
        self.recipeDetailView = recipeDetailView
        self.recipeTemplateListView = recipeTemplateListView
        self.recipeAmountView = recipeAmountView
        self.workoutSessionDetailView = workoutSessionDetailView
        self.mealDetailView = mealDetailView
        self.profileGoalsDetailView = profileGoalsDetailView
        self.profileEditView = profileEditView
        self.profileNutritionDetailView = profileNutritionDetailView
        self.profilePhysicalStatsView = profilePhysicalStatsView
        self.settingsView = settingsView
        self.manageSubscriptionView = manageSubscriptionView
        self.programPreviewView = programPreviewView
        self.customProgramBuilderView = customProgramBuilderView
        self.programGoalsView = programGoalsView
        self.programScheduleView = programScheduleView
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.templates.isEmpty {
                    ContentUnavailableView(
                        configuration.emptyStateTitle,
                        systemImage: configuration.emptyStateIcon,
                        description: Text(configuration.emptyStateDescription)
                    )
                } else {
                    List {
                        ForEach(viewModel.templates) { template in
                            CustomListCellView(
                                imageName: template.imageURL,
                                title: template.name,
                                subtitle: template.description
                            )
                            .anyButton(.highlight) {
                                viewModel.path.append(viewModel.navigationDestination(for: template))
                            }
                            .removeListRowFormatting()
                        }
                    }
                }
            }
            .navigationTitle(configuration.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .task {
                await viewModel.loadTemplates(templateIds: templateIdsOverride ?? viewModel.templateIds)
            }
            .if(supportsRefresh) { view in
                view.refreshable {
                    await viewModel.loadTemplates(templateIds: templateIdsOverride ?? viewModel.templateIds)
                }
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .navDestinationForTabBarModule(
                path: $viewModel.path,
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
        }
    }
}

// Helper extension for conditional view modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

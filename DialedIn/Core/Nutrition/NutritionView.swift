//
//  NutritionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct NutritionViewDelegate {
    var path: Binding<[TabBarPathOption]>
}

struct NutritionView: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var viewModel: NutritionViewModel
    
    var delegate: NutritionViewDelegate

    @ViewBuilder var devSettingsView: () -> AnyView
    @ViewBuilder var notificationsView: () -> AnyView
    @ViewBuilder var createIngredientView: () -> AnyView
    @ViewBuilder var createRecipeView: () -> AnyView
    @ViewBuilder var mealLogView: (MealLogViewDelegate) -> AnyView
    @ViewBuilder var recipesView: (RecipesViewDelegate) -> AnyView
    @ViewBuilder var ingredientsView: (IngredientsViewDelegate) -> AnyView
    @ViewBuilder var ingredientDetailView: (IngredientDetailViewDelegate) -> AnyView
    @ViewBuilder var recipeDetailView: (RecipeDetailViewDelegate) -> AnyView

    @ViewBuilder var exerciseTemplateDetailView: (ExerciseTemplateDetailViewDelegate) -> AnyView
    @ViewBuilder var exerciseTemplateListView: (ExerciseTemplateListViewDelegate) -> AnyView
    @ViewBuilder var workoutTemplateListView: (WorkoutTemplateListViewDelegate) -> AnyView
    @ViewBuilder var workoutTemplateDetailView: (WorkoutTemplateDetailViewDelegate) -> AnyView
    @ViewBuilder var ingredientTemplateListView: (IngredientTemplateListViewDelegate) -> AnyView
    @ViewBuilder var ingredientAmountView: (IngredientAmountViewDelegate) -> AnyView
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
    
    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack(path: delegate.path) {
                    contentView
                }
                .navDestinationForTabBarModule(
                    path: delegate.path,
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
            } else {
                contentView
            }
        }
        // Only show inspector in compact/tabBar modes; not in split view where detail is used
        .inspectorIfCompact(isPresented: $viewModel.isShowingInspector, inspector: { inspectorContent }, enabled: layoutMode != .splitView)
        .onChange(of: viewModel.selectedIngredientTemplate) { _, ingredient in
            guard layoutMode == .splitView else { return }
            if let ingredient { delegate.path.wrappedValue = [.ingredientTemplateDetail(template: ingredient)] }
        }
        .onChange(of: viewModel.selectedRecipeTemplate) { _, recipe in
            guard layoutMode == .splitView else { return }
            if let recipe { delegate.path.wrappedValue = [.recipeTemplateDetail(template: recipe)] }
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            List {
                pickerSection
                listContents
            }
            .scrollIndicators(.hidden)
            .showCustomAlert(alert: $viewModel.showAlert)
            #if DEBUG || MOCK
            .sheet(isPresented: $viewModel.showDebugView) {
                devSettingsView()
            }
            #endif
            .sheet(isPresented: $viewModel.showNotifications) {
                notificationsView()
            }
            .sheet(isPresented: $viewModel.showCreateIngredient) {
                createIngredientView()
            }
            .sheet(isPresented: $viewModel.showCreateRecipe) {
                createRecipeView()
            }
        }
        .navigationTitle("Nutrition")
        .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
    }

    private var pickerSection: some View {
        Section {
            Picker("Section", selection: $viewModel.presentationMode) {
                Text("Meal Log").tag(NutritionViewModel.NutritionPresentationMode.log)
                Text("Recipes").tag(NutritionViewModel.NutritionPresentationMode.recipes)
                Text("Ingredients").tag(NutritionViewModel.NutritionPresentationMode.ingredients)
            }
            .pickerStyle(.segmented)
        }
        .listSectionSpacing(0)
        .removeListRowFormatting()
    }
    
    private var listContents: some View {
        Group {
            switch viewModel.presentationMode {
            case .log:
                mealLogView(
                    MealLogViewDelegate(
                        path: delegate.path,
                        isShowingInspector: $viewModel.isShowingInspector,
                        selectedIngredientTemplate: $viewModel.selectedIngredientTemplate,
                        selectedRecipeTemplate: $viewModel.selectedRecipeTemplate
                    )
                )
            case .recipes:
                recipesView(
                    RecipesViewDelegate(
                        showCreateRecipe: $viewModel.showCreateRecipe,
                        selectedIngredientTemplate: $viewModel.selectedIngredientTemplate,
                        selectedRecipeTemplate: $viewModel.selectedRecipeTemplate,
                        isShowingInspector: $viewModel.isShowingInspector
                    )
                )
            case .ingredients:
                ingredientsView(
                    IngredientsViewDelegate(
                        isShowingInspector: $viewModel.isShowingInspector,
                        selectedIngredientTemplate: $viewModel.selectedIngredientTemplate,
                        selectedRecipeTemplate: $viewModel.selectedRecipeTemplate,
                        showCreateIngredient: $viewModel.showCreateIngredient
                    )
                )
            }
        }
    }
    
    private var inspectorContent: some View {
        Group {
            if let ingredient = viewModel.selectedIngredientTemplate {
                NavigationStack {
                    ingredientDetailView(
                        IngredientDetailViewDelegate(
                            ingredientTemplate: ingredient
                        )
                    )
                }
            } else if let recipe = viewModel.selectedRecipeTemplate {
                NavigationStack {
                    recipeDetailView(
                        RecipeDetailViewDelegate(
                            recipeTemplate: recipe
                        )
                    )
                }
            } else {
                Text("Select an item")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .inspectorColumnWidth(min: 300, ideal: 400, max: 600)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
    }
}

#Preview {
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.nutritionView(delegate: NutritionViewDelegate(path: $path))
    .previewEnvironment()
}

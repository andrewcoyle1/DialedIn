//
//  TabBarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI

struct TabBarViewDelegate {

    var path: Binding<[TabBarPathOption]>
    var tab: Binding<TabBarOption>
}

struct TabBarView: View {

    @State var viewModel: TabBarViewModel

    var delegate: TabBarViewDelegate

    @ViewBuilder var tabViewAccessoryView: (TabViewAccessoryViewDelegate) -> AnyView
    @ViewBuilder var workoutTrackerView: (WorkoutTrackerViewDelegate) -> AnyView
    @ViewBuilder var tabRootView: (TabBarOption, Binding<[TabBarPathOption]>) -> AnyView

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

    var body: some View {
        TabView(selection: delegate.tab) {
            ForEach(TabBarOption.allCases) { tab in
                Tab(tab.name, systemImage: tab.symbolName, value: tab) {
                    NavigationStack(path: delegate.path) {
                        tabRootView(delegate.tab.wrappedValue, delegate.path)

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
                }
            }
        }
        .tabViewStyle(.tabBarOnly)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            if let active = viewModel.active, !viewModel.trackerPresented {
                tabViewAccessoryView(TabViewAccessoryViewDelegate(active: active))
            }
        }
        .fullScreenCover(isPresented: Binding(get: {
            viewModel.isTrackerPresented
        }, set: { newValue in
            viewModel.isTrackerPresented = newValue
        })) {
            if let session = viewModel.activeSession {
                workoutTrackerView(WorkoutTrackerViewDelegate(workoutSession: session))
            }
        }
        .task {
            _ = viewModel.checkForActiveSession()
        }
    }
}

#Preview("Has No Active Session") {
    @Previewable @State var path: [TabBarPathOption] = []
    @Previewable @State var tab: TabBarOption = .dashboard
    let delegate = TabBarViewDelegate(path: $path, tab: $tab)
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.tabBarView(delegate: delegate)
    .previewEnvironment()
}

#Preview("Has Active Session") {
    @Previewable @State var path: [TabBarPathOption] = []
    @Previewable @State var tab: TabBarOption = .dashboard
    let delegate = TabBarViewDelegate(path: $path, tab: $tab)
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.tabBarView(delegate: delegate)
    .previewEnvironment()
}

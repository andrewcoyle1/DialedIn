//
//  SplitViewContainer.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct SplitViewDelegate {
    var path: Binding<[TabBarPathOption]>
    var tab: Binding<TabBarOption>
}

struct SplitViewContainer: View {

    @State var viewModel: SplitViewContainerViewModel

    var delegate: SplitViewDelegate

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
        NavigationSplitView(columnVisibility: .constant(.all), preferredCompactColumn: $viewModel.preferredColumn) {
            // Sidebar
            List {
                Section {
                    ForEach(TabBarOption.allCases, id: \.self) { section in
                        Button {
                            delegate.tab.wrappedValue = section
                        } label: {
                            Label(section.id, systemImage: section.symbolName)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let active = viewModel.activeSession, !viewModel.isTrackerPresented {
                    tabViewAccessoryView(TabViewAccessoryViewDelegate(active: active))
                        .padding()
                        .buttonStyle(.bordered)
                }
            }
            .frame(minWidth: 150)
        } content: {
            NavigationStack {
                tabRootView(delegate.tab.wrappedValue, delegate.path)
            }
            .background(
                Color(uiColor: .systemGroupedBackground)
            )
        } detail: {
            NavigationStack(path: delegate.path) {
                detailPlaceholder
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
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: Binding(get: {
            viewModel.isTrackerPresented
        }, set: { newValue in
            viewModel.isTrackerPresented = newValue
        })) {
            if let session = viewModel.activeSession {
                workoutTrackerView(WorkoutTrackerViewDelegate(workoutSession: session))
            }
        }
        .task {
            // Load any active session from local storage when the SplitView appears
            if let active = try? viewModel.getActiveLocalWorkoutSession() {
                viewModel.activeSession = active
            }
        }
    }
}

#Preview {
    @Previewable @State var path: [TabBarPathOption] = []
    @Previewable @State var tab: TabBarOption = .dashboard
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.splitViewContainer(delegate: SplitViewDelegate(path: $path, tab: $tab))
    .previewEnvironment()
}

private extension SplitViewContainer {
    var detailPlaceholder: some View {
        Text("Select an item to view details")
            .foregroundStyle(.secondary)
            .padding()
    }
}

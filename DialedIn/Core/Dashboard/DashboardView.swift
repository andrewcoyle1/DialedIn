//
//  DashboardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct DashboardViewDelegate {
    var path: Binding<[TabBarPathOption]>
}

struct DashboardView: View {
    @Environment(\.layoutMode) private var layoutMode

    @State var viewModel: DashboardViewModel

    var delegate: DashboardViewDelegate

    @ViewBuilder var devSettingsView: () -> AnyView
    @ViewBuilder var notificationsView: () -> AnyView
    @ViewBuilder var nutritionTargetChartView: () -> AnyView

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
        .inspectorIfCompact(isPresented: $viewModel.isShowingInspector, inspector: { inspectorContent }, enabled: layoutMode != .splitView)
    }
    
    private var contentView: some View {
        List {
            carouselSection
            nutritionTargetSection
            contributionChartSection
        }
        .navigationTitle("Dashboard")
        .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            devSettingsView()
        }
        #endif
        .sheet(isPresented: $viewModel.showNotifications) {
            notificationsView()
        }
        .onOpenURL { url in
            viewModel.handleDeepLink(url: url)
        }
    }
    
    private var inspectorContent: some View {
        Group {
            Text("Select an item")
                .foregroundStyle(.secondary)
                .padding()
        }
        .inspectorColumnWidth(min: 300, ideal: 400, max: 600)
    }
    
    private var carouselSection: some View {
        Section {
            
        } header: {
            
        }
    }
    
    private var nutritionTargetSection: some View {
        Section {
            nutritionTargetChartView()
        } header: {
            Text("Nutrition & Targets")
        }
    }
    
    private var contributionChartSection: some View {
        Section {
            ContributionChartView(
                data: viewModel.contributionChartData,
                rows: 7,
                columns: 16,
                targetValue: 1.0,
                blockColor: .accent,
                endDate: viewModel.chartEndDate
            )
            .frame(height: 220)
        } header: {
            Text("Workout Consistency")
        }
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
                viewModel.onPushNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
    }
}

#Preview {
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.dashboardView(delegate: DashboardViewDelegate(path: $path))
    .previewEnvironment()
}

//
//  CoreBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/11/2025.
//

import SwiftUI

@Observable
@MainActor
class CoreBuilder {

    let interactor: CoreInteractor

    init(container: DependencyContainer) {
        interactor = CoreInteractor(container: container)
    }

    func adaptiveMainView() -> some View {
        AdaptiveMainView(
            viewModel: AdaptiveMainViewModel(interactor: interactor)
        )
    }

    func tabBarView(delegate: TabBarViewDelegate) -> some View {
        TabBarView(
            viewModel: TabBarViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func splitViewContainer(delegate: SplitViewDelegate) -> some View {
        SplitViewContainer(
            viewModel: SplitViewContainerViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func exerciseTemplateDetailView(delegate: ExerciseTemplateDetailViewDelegate) -> some View {
        ExerciseTemplateDetailView(
            viewModel: ExerciseTemplateDetailViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func tabViewAccessoryView(delegate: TabViewAccessoryViewDelegate) -> some View {
        TabViewAccessoryView(
            viewModel: TabViewAccessoryViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func workoutTrackerView(delegate: WorkoutTrackerViewDelegate) -> some View {
        WorkoutTrackerView(
            viewModel: WorkoutTrackerViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func ingredientDetailView(delegate: IngredientDetailViewDelegate) -> some View {
        IngredientDetailView(
            viewModel: IngredientDetailViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func exerciseTemplateListView(delegate: ExerciseTemplateListViewDelegate) -> some View {
        ExerciseTemplateListView(
            viewModel: ExerciseTemplateListViewModel.create(interactor: interactor),
            delegate: delegate
        )
    }

    func workoutTemplateListView(delegate: WorkoutTemplateListViewDelegate) -> some View {
        WorkoutTemplateListView(
            viewModel: WorkoutTemplateListViewModel.create(interactor: interactor),
            delegate: delegate
        )
    }

    func workoutTemplateDetailView(delegate: WorkoutTemplateDetailViewDelegate) -> some View {
        WorkoutTemplateDetailView(
            viewModel: WorkoutTemplateDetailViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func workoutSessionDetailView(delegate: WorkoutSessionDetailViewDelegate) -> some View {
        WorkoutSessionDetailView(
            viewModel: WorkoutSessionDetailViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func programView(delegate: ProgramViewDelegate) -> some View {
        ProgramView(
            viewModel: ProgramViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func devSettingsView() -> some View {
        DevSettingsView(
            viewModel: DevSettingsViewModel(interactor: interactor)
        )
    }

    func workoutStartView(delegate: WorkoutStartViewDelegate) -> some View {
        WorkoutStartView(
            viewModel: WorkoutStartViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func dashboardView(delegate: DashboardViewDelegate) -> some View {
        DashboardView(
            viewModel: DashboardViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func createIngredientView() -> some View {
        CreateIngredientView(
            viewModel: CreateIngredientViewModel(interactor: interactor)
        )
    }

    func addIngredientModalView(delegate: AddIngredientModalViewDelegate) -> some View {
        AddIngredientModalView(
            viewModel: AddIngredientModalViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func createRecipeView() -> some View {
        CreateRecipeView(
            viewModel: CreateRecipeViewModel(interactor: interactor)
        )
    }

    func mealLogView(delegate: MealLogViewDelegate) -> some View {
        MealLogView(
            viewModel: MealLogViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func recipesView(delegate: RecipesViewDelegate) -> some View {
        RecipesView(
            viewModel: RecipesViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func ingredientsView(delegate: IngredientsViewDelegate) -> some View {
        IngredientsView(
            viewModel: IngredientsViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func nutritionView(delegate: NutritionViewDelegate) -> some View {
        NutritionView(
            viewModel: NutritionViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func nutritionLibraryPickerView(delegate: NutritionLibraryPickerViewDelegate) -> some View {
        NutritionLibraryPickerView(
            viewModel: NutritionLibraryPickerViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func addMealSheet(delegate: AddMealSheetDelegate) -> some View {
        AddMealSheet(
            viewModel: AddMealSheetViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func nutritionTargetChartView() -> some View {
        NutritionTargetChartView(
            viewModel: NutritionTargetChartViewModel(interactor: interactor)
        )
    }

    func workoutsView(delegate: WorkoutsViewDelegate) -> some View {
        WorkoutsView(
            viewModel: WorkoutsViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func workoutHistoryView(delegate: WorkoutHistoryViewDelegate) -> some View {
        WorkoutHistoryView(
            viewModel: WorkoutHistoryViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func createWorkoutView(delegate: CreateWorkoutViewDelegate) -> some View {
        CreateWorkoutView(
            viewModel: CreateWorkoutViewModel(interactor: interactor),
            delegate: delegate)
    }

    func createExerciseView() -> some View {
        CreateExerciseView(
            viewModel: CreateExerciseViewModel(interactor: interactor)
        )
    }

    func addGoalView(delegate: AddGoalViewDelegate) -> some View {
        AddGoalView(
            viewModel: AddGoalViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func workoutSummaryCardView(delegate: WorkoutSummaryCardViewDelegate) -> some View {
        WorkoutSummaryCardView(
            viewModel: WorkoutSummaryCardViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func todaysWorkoutCardView(delegate: TodaysWorkoutCardViewDelegate) -> some View {
        TodaysWorkoutCardView(
            viewModel: TodaysWorkoutCardViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func scheduledWorkoutRowView(scheduledWorkout: ScheduledWorkout) -> some View {
        ScheduledWorkoutRowView(
            viewModel: ScheduledWorkoutRowViewModel(
                interactor: interactor,
                scheduledWorkout: scheduledWorkout
            )
        )
    }

    func programRowView(delegate: ProgramRowViewDelegate) -> some View {
        ProgramRowView(
            viewModel: ProgramRowViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func workoutCalendarView(delegate: WorkoutCalendarViewDelegate) -> some View {
        WorkoutCalendarView(
            viewModel: WorkoutCalendarViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func editableExerciseCardWrapper(delegate: EditableExerciseCardWrapperDelegate) -> some View {
        EditableExerciseCardWrapper(
            delegate: delegate,
            interactor: interactor
        )
    }

    func exercisesView(delegate: ExercisesViewDelegate) -> some View {
        ExercisesView(
            viewModel: ExercisesViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func programManagementView(delegate: ProgramManagementViewDelegate) -> some View {
        ProgramManagementView(
            viewModel: ProgramManagementViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func trainingView(delegate: TrainingViewDelegate) -> some View {
        TrainingView(
            viewModel: TrainingViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func progressDashboardView() -> some View {
        ProgressDashboardView(viewModel: ProgressDashboardViewModel(interactor: interactor))
    }

    func strengthProgressView() -> some View {
        StrengthProgressView(viewModel: StrengthProgressViewModel(interactor: interactor))
    }

    func workoutHeatmapView() -> some View {
        WorkoutHeatmapView(viewModel: WorkoutHeatmapViewModel(interactor: interactor))
    }

    func notificationsView() -> some View {
        NotificationsView(viewModel: NotificationsViewModel(interactor: interactor))
    }

    func programGoalsView(plan: TrainingPlan) -> some View {
        ProgramGoalsView(viewModel: ProgramGoalsViewModel(interactor: interactor, plan: plan))
    }

    func programScheduleView(plan: TrainingPlan) -> some View {
        ProgramScheduleView(viewModel: ProgramScheduleViewModel(interactor: interactor), plan: plan)
    }

    func mealDetailView(meal: MealLogModel) -> some View {
        MealDetailView(viewModel: MealDetailViewModel(interactor: interactor, meal: meal))
    }

    func profileGoalsDetailView() -> some View {
        ProfileGoalsDetailView(viewModel: ProfileGoalsDetailViewModel(interactor: interactor))
    }

    func profileEditView() -> some View {
        ProfileEditView(viewModel: ProfileEditViewModel(interactor: interactor))
    }

    func profileNutritionDetailView() -> some View {
        ProfileNutritionDetailView(viewModel: ProfileNutritionDetailViewModel(interactor: interactor))
    }

    func profilePhysicalStatsView() -> some View {
        ProfilePhysicalStatsView(viewModel: ProfilePhysicalStatsViewModel(interactor: interactor))
    }

    func settingsView(path: Binding<[TabBarPathOption]>) -> some View {
        SettingsView(viewModel: SettingsViewModel(interactor: interactor), path: path)
    }

    func ingredientTemplateListView(templateIds: [String]) -> some View {
        IngredientTemplateListView(interactor: interactor, templateIds: templateIds)
    }

    func ingredientAmountView(ingredient: IngredientTemplateModel, onPick: @escaping (MealItemModel) -> Void) -> some View {
        IngredientAmountView(
            viewModel: IngredientAmountViewModel(
                interactor: interactor,
                ingredient: ingredient,
                onConfirm: onPick
            )
        )
    }

    func goalRow(delegate: GoalRowDelegate) -> some View {
        GoalRow(
            viewModel: GoalRowViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func programTemplatePickerView(path: Binding<[TabBarPathOption]>) -> some View {
        ProgramTemplatePickerView(
            viewModel: ProgramTemplatePickerViewModel(interactor: interactor),
            path: path
        )
    }

    func editProgramView(delegate: EditProgramViewDelegate) -> some View {
        EditProgramView(
            viewModel: EditProgramViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func enhancedScheduleView(delegate: EnhancedScheduleViewDelegate) -> some View {
        EnhancedScheduleView(
            viewModel: EnhancedScheduleViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func logWeightView() -> some View {
        LogWeightView(viewModel: LogWeightViewModel(interactor: interactor))
    }

    func profileHeaderView(path: Binding<[TabBarPathOption]>) -> some View {
        ProfileHeaderView(
            viewModel: ProfileHeaderViewModel(interactor: interactor),
            path: path
        )
    }

    func profilePhysicalMetricsView(path: Binding<[TabBarPathOption]>) -> some View {
        ProfilePhysicalMetricsView(
            viewModel: ProfilePhysicalMetricsViewModel(interactor: interactor),
            path: path
        )
    }

    func profileGoalsSection(path: Binding<[TabBarPathOption]>) -> some View {
        ProfileGoalSection(
            viewModel: ProfileGoalSectionViewModel(interactor: interactor),
            path: path
        )
    }

    func profileNutritionPlanView(path: Binding<[TabBarPathOption]>) -> some View {
        ProfileNutritionPlanView(
            viewModel: ProfileNutritionPlanViewModel(interactor: interactor),
            path: path
        )
    }

    func profilePreferencesView(path: Binding<[TabBarPathOption]>) -> some View {
        ProfilePreferencesView(
            viewModel: ProfilePreferencesViewModel(interactor: interactor),
            path: path
        )
    }

    func profileMyTemplatesView(path: Binding<[TabBarPathOption]>) -> some View {
        ProfileMyTemplatesView(
            viewModel: ProfileMyTemplatesViewModel(interactor: interactor),
            path: path
        )
    }

    func recipeDetailView(recipeTemplate: RecipeTemplateModel) -> some View {
        RecipeDetailView(
            viewModel: RecipeDetailViewModel(
                interactor: interactor,
                recipeTemplate: recipeTemplate
            )
        )
    }

    func recipeTemplateListView(templateIds: [String]) -> some View {
        RecipeTemplateListView(interactor: interactor, templateIds: templateIds)
    }

    func customProgramBuilderView(path: Binding<[TabBarPathOption]>) -> some View {
        CustomProgramBuilderView(
            viewModel: CustomProgramBuilderViewModel(interactor: interactor),
            path: path
        )
    }

    func programPreviewView(template: ProgramTemplateModel, startDate: Date) -> some View {
        ProgramPreviewView(
            viewModel: ProgramPreviewViewModel(interactor: interactor),
            template: template,
            startDate: startDate
        )
    }

    func manageSubscriptionView() -> some View {
        ManageSubscriptionView()
    }

    func recipeAmountView(recipe: RecipeTemplateModel, onPick: @escaping (MealItemModel) -> Void) -> some View {
        RecipeAmountView(
            viewModel: RecipeAmountViewModel(
                interactor: interactor,
                recipe: recipe,
                onConfirm: onPick
            )
        )
    }

    func programStartConfigView(delegate: ProgramStartConfigViewDelegate) -> some View {
        ProgramStartConfigView(
            viewModel: ProgramStartConfigViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func volumeChartsView() -> some View {
         VolumeChartsView(
            viewModel: VolumeChartsViewModel(interactor: interactor)
         )
    }

    func workoutPickerSheet(delegate: WorkoutPickerSheetDelegate) -> some View {
        WorkoutPickerSheet(
            interactor: interactor,
            delegate: delegate
        )
    }

    func trendSummarySection(trend: VolumeTrend) -> some View {
        TrendSummarySection(
            viewModel: TrendSummarySectionViewModel(
                interactor: interactor,
                trend: trend
            )
        )
    }

    func setTrackerRowView(delegate: SetTrackerRowViewDelegate) -> some View {
        SetTrackerRowView(
            viewModel: SetTrackerRowViewModel(interactor: interactor),
            delegate: delegate,
        )
    }

    func profileView(path: Binding<[TabBarPathOption]>) -> some View {
        ProfileView(viewModel: ProfileViewModel(interactor: interactor), path: path)
    }

    func createAccountView() -> some View {
        CreateAccountView(viewModel: CreateAccountViewModel(interactor: interactor))
    }

    func addExerciseModalView(delegate: AddExerciseModalViewDelegate) -> some View {
        AddExerciseModalView(
            viewModel: AddExerciseModalViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func profileGoalSection(path: Binding<[TabBarPathOption]>) -> some View {
        ProfileGoalSection(
            viewModel: ProfileGoalSectionViewModel(interactor: interactor),
            path: path
        )
    }

    func dayScheduleSheetView(delegate: DayScheduleSheetViewDelegate) -> some View {
        DayScheduleSheetView(
            viewModel: DayScheduleSheetViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func exerciseTrackerCardView(delegate: ExerciseTrackerCardViewDelegate) -> some View {
        ExerciseTrackerCardView(
            delegate: delegate,
            interactor: interactor
        )
    }
}

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
            delegate: delegate
        )
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

    func scheduledWorkoutRowView(delegate: ScheduledWorkoutRowViewDelegate) -> some View {
        ScheduledWorkoutRowView(
            viewModel: ScheduledWorkoutRowViewModel(interactor: interactor),
            delegate: delegate
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
        ProgressDashboardView(
            viewModel: ProgressDashboardViewModel(interactor: interactor)
        )
    }

    func strengthProgressView() -> some View {
        StrengthProgressView(
            viewModel: StrengthProgressViewModel(interactor: interactor)
        )
    }

    func workoutHeatmapView() -> some View {
        WorkoutHeatmapView(
            viewModel: WorkoutHeatmapViewModel(interactor: interactor)
        )
    }

    func notificationsView() -> some View {
        NotificationsView(
            viewModel: NotificationsViewModel(interactor: interactor)
        )
    }

    func programGoalsView(delegate: ProgramGoalsViewDelegate) -> some View {
        ProgramGoalsView(
            viewModel: ProgramGoalsViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func programScheduleView(delegate: ProgramScheduleViewDelegate) -> some View {
        ProgramScheduleView(
            viewModel: ProgramScheduleViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func mealDetailView(delegate: MealDetailViewDelegate) -> some View {
        MealDetailView(
            viewModel: MealDetailViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func profileGoalsDetailView() -> some View {
        ProfileGoalsDetailView(
            viewModel: ProfileGoalsDetailViewModel(interactor: interactor)
        )
    }

    func profileEditView() -> some View {
        ProfileEditView(
            viewModel: ProfileEditViewModel(interactor: interactor)
        )
    }

    func profileNutritionDetailView() -> some View {
        ProfileNutritionDetailView(
            viewModel: ProfileNutritionDetailViewModel(interactor: interactor)
        )
    }

    func profilePhysicalStatsView() -> some View {
        ProfilePhysicalStatsView(
            viewModel: ProfilePhysicalStatsViewModel(interactor: interactor)
        )
    }

    func settingsView(delegate: SettingsViewDelegate) -> some View {
        SettingsView(
            viewModel: SettingsViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func ingredientTemplateListView(delegate: IngredientTemplateListViewDelegate) -> some View {
        IngredientTemplateListView(
            interactor: interactor,
            delegate: delegate
        )
    }

    func ingredientAmountView(delegate: IngredientAmountViewDelegate) -> some View {
        IngredientAmountView(
            viewModel: IngredientAmountViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func goalRow(delegate: GoalRowDelegate) -> some View {
        GoalRow(
            viewModel: GoalRowViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func programTemplatePickerView(delegate: ProgramTemplatePickerViewDelegate) -> some View {
        ProgramTemplatePickerView(
            viewModel: ProgramTemplatePickerViewModel(interactor: interactor),
            delegate: delegate
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
        LogWeightView(
            viewModel: LogWeightViewModel(interactor: interactor)
        )
    }

    func profileHeaderView(delegate: ProfileHeaderViewDelegate) -> some View {
        ProfileHeaderView(
            viewModel: ProfileHeaderViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func profilePhysicalMetricsView(delegate: ProfilePhysicalMetricsViewDelegate) -> some View {
        ProfilePhysicalMetricsView(
            viewModel: ProfilePhysicalMetricsViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func profileGoalSection(delegate: ProfileGoalSectionDelegate) -> some View {
        ProfileGoalSection(
            viewModel: ProfileGoalSectionViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func profileNutritionPlanView(delegate: ProfileNutritionPlanViewDelegate) -> some View {
        ProfileNutritionPlanView(
            viewModel: ProfileNutritionPlanViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func profilePreferencesView(delegate: ProfilePreferencesViewDelegate) -> some View {
        ProfilePreferencesView(
            viewModel: ProfilePreferencesViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func profileMyTemplatesView(delegate: ProfileMyTemplatesViewDelegate) -> some View {
        ProfileMyTemplatesView(
            viewModel: ProfileMyTemplatesViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func recipeDetailView(delegate: RecipeDetailViewDelegate) -> some View {
        RecipeDetailView(
            viewModel: RecipeDetailViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func recipeTemplateListView(delegate: RecipeTemplateListViewDelegate) -> some View {
        RecipeTemplateListView(
            interactor: interactor,
            delegate: delegate
        )
    }

    func customProgramBuilderView(delegate: CustomProgramBuilderViewDelegate) -> some View {
        CustomProgramBuilderView(
            viewModel: CustomProgramBuilderViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func programPreviewView(delegate: ProgramPreviewViewDelegate) -> some View {
        ProgramPreviewView(
            viewModel: ProgramPreviewViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func manageSubscriptionView() -> some View {
        ManageSubscriptionView()
    }

    func recipeAmountView(delegate: RecipeAmountViewDelegate) -> some View {
        RecipeAmountView(
            viewModel: RecipeAmountViewModel(interactor: interactor),
            delegate: delegate
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

    func trendSummarySection(delegate: TrendSummarySectionDelegate) -> some View {
        TrendSummarySection(
            viewModel: TrendSummarySectionViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func setTrackerRowView(delegate: SetTrackerRowViewDelegate) -> some View {
        SetTrackerRowView(
            viewModel: SetTrackerRowViewModel(interactor: interactor),
            delegate: delegate,
        )
    }

    func profileView(delegate: ProfileViewDelegate) -> some View {
        ProfileView(
            viewModel: ProfileViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func createAccountView() -> some View {
        CreateAccountView(
            viewModel: CreateAccountViewModel(interactor: interactor)
        )
    }

    func addExerciseModalView(delegate: AddExerciseModalViewDelegate) -> some View {
        AddExerciseModalView(
            viewModel: AddExerciseModalViewModel(interactor: interactor),
            delegate: delegate
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

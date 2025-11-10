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
        AdaptiveMainView(viewModel: AdaptiveMainViewModel(interactor: interactor))
    }

    func tabBarView(path: Binding<[TabBarPathOption]>, tab: Binding<TabBarOption>) -> some View {
        TabBarView(viewModel: TabBarViewModel(interactor: interactor), path: path, tab: tab)
    }

    func splitViewContainer(path: Binding<[TabBarPathOption]>, tab: Binding<TabBarOption>) -> some View {
        SplitViewContainer(viewModel: SplitViewContainerViewModel(interactor: interactor), path: path, tab: tab)
    }

    func exerciseTemplateDetailView(exercise: ExerciseTemplateModel) -> some View {
        ExerciseTemplateDetailView(
            viewModel: ExerciseTemplateDetailViewModel(interactor: interactor),
            exerciseTemplate: exercise
        )
    }

    func ingredientDetailView(ingredientTemplate: IngredientTemplateModel) -> some View {
        IngredientDetailView(
            viewModel: IngredientDetailViewModel(
                interactor: interactor,
                ingredientTemplate: ingredientTemplate
            )
        )
    }

    func exerciseTemplateListView(templateIds: [String]) -> some View {
        ExerciseTemplateListView(
            interactor: interactor,
            templateIds: templateIds
        )
    }

    func workoutTemplateListView(templateIds: [String]) -> some View {
        WorkoutTemplateListView(
            interactor: interactor,
            templateIds: templateIds
        )
    }

    func workoutTemplateDetailView(workout: WorkoutTemplateModel) -> some View {
        WorkoutTemplateDetailView(
            viewModel: WorkoutTemplateDetailViewModel(interactor: interactor),
            workoutTemplate: workout
        )
    }

    func workoutSessionDetailView(session: WorkoutSessionModel) -> some View {
        WorkoutSessionDetailView(
            viewModel: WorkoutSessionDetailViewModel(interactor: interactor),
            workoutSession: session
        )
    }

    func programView(onSessionSelectionChangeded: @escaping (WorkoutSessionModel?) -> Void, onWorkoutStartRequested: @escaping (WorkoutTemplateModel, ScheduledWorkout?) -> Void, onActiveSheetChanged: @escaping (ActiveSheet?) -> Void) -> some View {
        ProgramView(
            viewModel: ProgramViewModel(
                interactor: interactor,
                onSessionSelectionChanged: onSessionSelectionChangeded,
                onWorkoutStartRequested: onWorkoutStartRequested,
                onActiveSheetChanged: onActiveSheetChanged
            )
        )
    }

    func devSettingsView() -> some View {
        DevSettingsView(viewModel: DevSettingsViewModel(interactor: interactor))
    }

    func workoutStartView(template: WorkoutTemplateModel, scheduledWorkout: ScheduledWorkout? = nil) -> some View {
        WorkoutStartView(
            viewModel: WorkoutStartViewModel(
                interactor: interactor
            ),
            template: template,
            scheduledWorkout: scheduledWorkout
        )
    }

    func dashboardView(path: Binding<[TabBarPathOption]>) -> some View {
        DashboardView(viewModel: DashboardViewModel(interactor: interactor), path: path)
    }

    func createIngredientView() -> some View {
        CreateIngredientView(viewModel: CreateIngredientViewModel(interactor: interactor))
    }

    func nutritionTargetChartView() -> some View {
        NutritionTargetChartView(viewModel: NutritionTargetChartViewModel(interactor: interactor))
    }

    func workoutsView(onWorkoutSelectionChanged: ((WorkoutTemplateModel) -> Void)? = nil) -> some View {
        WorkoutsView(
            viewModel: WorkoutsViewModel(
                interactor: interactor,
                onWorkoutSelectionChanged: onWorkoutSelectionChanged
            )
        )
    }

    func workoutHistoryView(onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)? = nil) -> some View {
        WorkoutHistoryView(
            viewModel: WorkoutHistoryViewModel(
                interactor: interactor,
                onSessionSelectionChanged: onSessionSelectionChanged
            )
        )
    }

    func createWorkoutView(workoutTemplate: WorkoutTemplateModel? = nil) -> some View {
        CreateWorkoutView(viewModel: CreateWorkoutViewModel(interactor: interactor), workoutTemplate: workoutTemplate)
    }

    func createExerciseView() -> some View {
        CreateExerciseView(viewModel: CreateExerciseViewModel(interactor: interactor))
    }

    func addGoalView(plan: TrainingPlan) -> some View {
        AddGoalView(viewModel: AddGoalViewModel(interactor: interactor), plan: plan)
    }

    func workoutSummaryCardView(scheduledWorkout: ScheduledWorkout, onTap: @escaping () -> Void) -> some View {
        WorkoutSummaryCardView(
            viewModel: WorkoutSummaryCardViewModel(
                interactor: interactor,
                scheduledWorkout: scheduledWorkout,
                onTap: onTap
            )
        )
    }

    func todaysWorkoutCardView(scheduledWorkout: ScheduledWorkout, onStart: @escaping () -> Void) -> some View {
        TodaysWorkoutCardView(
            viewModel: TodaysWorkoutCardViewModel(interactor: interactor,
            scheduledWorkout: scheduledWorkout,
            onStart: onStart)
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

    func workoutCalendarView(onSessionSelectionChanged: @escaping (WorkoutSessionModel) -> Void, onWorkoutStartRequested: @escaping (WorkoutTemplateModel, ScheduledWorkout?) -> Void) -> some View {
        WorkoutCalendarView(
            viewModel: WorkoutCalendarViewModel(
                interactor: interactor, onSessionSelectionChanged: onSessionSelectionChanged,
                onWorkoutStartRequested: onWorkoutStartRequested
            )
        )

    }
    // swiftlint:disable:next function_parameter_count
    func editableExerciseCardWrapper(
        exercise: WorkoutExerciseModel,
        index: Int,
        weightUnit: ExerciseWeightUnit,
        distanceUnit: ExerciseDistanceUnit,
        onExerciseUpdate: @escaping (WorkoutExerciseModel) -> Void,
        onAddSet: @escaping () -> Void,
        onDeleteSet: @escaping (String) -> Void,
        onWeightUnitChange: @escaping (ExerciseWeightUnit) -> Void,
        onDistanceUnitChange: @escaping (ExerciseDistanceUnit) -> Void
    ) -> some View {
        EditableExerciseCardWrapper(
            viewModel: EditableExerciseCardWrapperViewModel(
                interactor: interactor,
                exercise: exercise,
                index: index,
                weightUnit: weightUnit,
                distanceUnit: distanceUnit,
                onExerciseUpdate: onExerciseUpdate,
                onAddSet: onAddSet,
                onDeleteSet: onDeleteSet,
                onWeightUnitChange: onWeightUnitChange,
                onDistanceUnitChange: onDistanceUnitChange
            )
        )
    }

    func addExerciseModalView(selectedExercises: Binding<[ExerciseTemplateModel]>) -> some View {
        AddExerciseModalView(
            viewModel: AddExerciseModalViewModel(
                interactor: interactor
            ),
            selectedExercises: selectedExercises
        )

    }

    func exercisesView(onExerciseSelectionChanged: ((ExerciseTemplateModel) -> Void)? = nil) -> some View {
        ExercisesView(
            viewModel: ExercisesViewModel(
                interactor: interactor,
                onExerciseSelectionChanged: onExerciseSelectionChanged
            )
        )
    }

    func programManagementView(path: Binding<[TabBarPathOption]>) -> some View {
        ProgramManagementView(
            viewModel: ProgramManagementViewModel(
                interactor: interactor
            ),
            path: path
        )
    }

    func trainingView(path: Binding<[TabBarPathOption]>) -> some View {
        TrainingView(viewModel: TrainingViewModel(interactor: interactor), path: path)
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
        CustomProgramBuilderView(viewModel: CustomProgramBuilderViewModel(interactor: interactor), path: path)
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
}

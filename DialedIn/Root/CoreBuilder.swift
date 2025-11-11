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

    func tabViewAccessoryView(active: WorkoutSessionModel) -> some View {
        TabViewAccessoryView(viewModel: TabViewAccessoryViewModel(interactor: interactor), active: active)
    }

    func workoutTrackerView(workoutSession: WorkoutSessionModel, initialWorkoutSession: WorkoutSessionModel) -> some View {
        WorkoutTrackerView(viewModel: WorkoutTrackerViewModel(interactor: interactor, workoutSession: workoutSession), initialWorkoutSession: initialWorkoutSession)
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

    func addIngredientModalView(selectedIngredients: Binding<[IngredientTemplateModel]>) -> some View {
        AddIngredientModalView(
            viewModel: AddIngredientModalViewModel(interactor: interactor),
            selectedIngredients: selectedIngredients
        )
    }

    func createRecipeView() -> some View {
        CreateRecipeView(viewModel: CreateRecipeViewModel(interactor: interactor))
    }

    func mealLogView(
        path: Binding<[TabBarPathOption]>,
        isShowingInspector: Binding<Bool>,
        selectedIngredientTemplate: Binding<IngredientTemplateModel?>,
        selectedRecipeTemplate: Binding<RecipeTemplateModel?>
    ) -> some View {
        MealLogView(
            viewModel: MealLogViewModel(interactor: interactor),
            path: path,
            isShowingInspector: isShowingInspector,
            selectedIngredientTemplate: selectedIngredientTemplate,
            selectedRecipeTemplate: selectedRecipeTemplate
        )
    }

    func recipesView(
        showCreateRecipe: Binding<Bool>,
        selectedIngredientTemplate: Binding<IngredientTemplateModel?>,
        selectedRecipeTemplate: Binding<RecipeTemplateModel?>,
        isShowingInspector: Binding<Bool>
    ) -> some View {
        RecipesView(
            viewModel: RecipesViewModel(
                interactor: interactor, showCreateRecipe: showCreateRecipe,
                selectedIngredientTemplate: selectedIngredientTemplate,
                selectedRecipeTemplate: selectedRecipeTemplate,
                isShowingInspector: isShowingInspector
            )
        )
    }

    func ingredientsView(
        isShowingInspector: Binding<Bool>,
        selectedIngredientTemplate: Binding<IngredientTemplateModel?>,
        selectedRecipeTemplate: Binding<RecipeTemplateModel?>,
        showCreateIngredient: Binding<Bool>
    ) -> some View {
        IngredientsView(
            viewModel: IngredientsViewModel(interactor: interactor),
            isShowingInspector: isShowingInspector,
            selectedIngredientTemplate: selectedIngredientTemplate,
            selectedRecipeTemplate: selectedRecipeTemplate,
            showCreateIngredient: showCreateIngredient
        )
    }

    func nutritionView(path: Binding<[TabBarPathOption]>) -> some View {
        NutritionView(
            viewModel: NutritionViewModel(
                interactor: interactor
            ),
            path: path
        )
    }

    func nutritionLibraryPickerView(onPick: @escaping (MealItemModel) -> Void, path: Binding<[TabBarPathOption]>) -> some View {
        NutritionLibraryPickerView(viewModel: NutritionLibraryPickerViewModel(interactor: interactor, onPick: onPick), path: path)
    }

    func addMealSheet(selectedDate: Date, mealType: MealType, onSave: @escaping (MealLogModel) -> Void, path: Binding<[TabBarPathOption]>) -> some View {
        AddMealSheet(
            viewModel: AddMealSheetViewModel(
                interactor: interactor,
                selectedDate: selectedDate,
                mealType: mealType,
                onSave: onSave
            ),
            path: path
        )
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

    func programRowView(
        plan: TrainingPlan,
        isActive: Bool,
        onActivate: @escaping () -> Void = {},
        onEdit: @escaping () -> Void = {},
        onDelete: @escaping () -> Void = {}
    ) -> some View {
        ProgramRowView(
            viewModel: ProgramRowViewModel(
                interactor: interactor,
                plan: plan,
                isActive: isActive,
                onActivate: onActivate,
                onEdit: onEdit,
                onDelete: onDelete
            )
        )
    }

    func workoutCalendarView(onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)? = nil, onWorkoutStartRequested: ((WorkoutTemplateModel, ScheduledWorkout?) -> Void)? = nil) -> some View {
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

    func goalRow(goal: TrainingGoal, plan: TrainingPlan) -> some View {
        GoalRow(
            viewModel: GoalRowViewModel(interactor: interactor, goal: goal, plan: plan))
    }

    func programTemplatePickerView(path: Binding<[TabBarPathOption]>) -> some View {
        ProgramTemplatePickerView(
            viewModel: ProgramTemplatePickerViewModel(interactor: interactor),
            path: path
        )
    }

    func editProgramView(path: Binding<[TabBarPathOption]>, plan: TrainingPlan) -> some View {
        EditProgramView(
            viewModel: EditProgramViewModel(
                interactor: interactor,
                plan: plan
            ),
            path: path,
            plan: plan
        )
    }

    func enhancedScheduleView(getScheduledWorkouts: @escaping () -> [ScheduledWorkout], onDateSelected: @escaping (Date) -> Void, onDateTapped: @escaping (Date) -> Void) -> some View {
        EnhancedScheduleView(viewModel: EnhancedScheduleViewModel(interactor: interactor, getScheduledWorkouts: getScheduledWorkouts, onDateSelected: onDateSelected, onDateTapped: onDateTapped))
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

    func programStartConfigView(
        path: Binding<[TabBarPathOption]>,
        template: ProgramTemplateModel,
        onStart: @escaping (Date, Date?, String?) -> Void
    ) -> some View {
        ProgramStartConfigView(
            viewModel: ProgramStartConfigViewModel(interactor: interactor),
            path: path,
            template: template,
            onStart: onStart
        )
    }

    func volumeChartsView() -> some View {
         VolumeChartsView(viewModel: VolumeChartsViewModel(interactor: interactor))
    }

    func workoutPickerSheet(
        onSelect: @escaping (WorkoutTemplateModel) -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        WorkoutPickerSheet(
            interactor: interactor,
            onSelect: onSelect,
            onCancel: onCancel
        )
    }

    func trendSummarySection(trend: VolumeTrend) -> some View {
        TrendSummarySection(
            viewModel: TrendSummarySectionViewModel(
                interactor: interactor,
                trend: trend)
        )
    }

    func setTrackerRowView(
        set: WorkoutSetModel,
        trackingMode: TrackingMode,
        weightUnit: ExerciseWeightUnit = .kilograms,
        distanceUnit: ExerciseDistanceUnit = .meters,
        previousSet: WorkoutSetModel? = nil,
        restBeforeSec: Int?,
        onRestBeforeChange: @escaping (
            Int?
        ) -> Void,
        onRequestRestPicker: @escaping (
            String,
            Int?
        ) -> Void = { _, _ in },
        onUpdate: @escaping (
            WorkoutSetModel
        ) -> Void
    ) -> some View {
        SetTrackerRowView(
            viewModel: SetTrackerRowViewModel(
                interactor: interactor,
                set: set,
                trackingMode: trackingMode,
                weightUnit: weightUnit,
                distanceUnit: distanceUnit,
                previousSet: previousSet,
                restBeforeSec: restBeforeSec,
                onRestBeforeChange: onRestBeforeChange,
                onRequestRestPicker: onRequestRestPicker,
                onUpdate: onUpdate
            )
        )
    }

    func profileView(path: Binding<[TabBarPathOption]>) -> some View {
        ProfileView(viewModel: ProfileViewModel(interactor: interactor), path: path)
    }

    func createAccountView() -> some View {
        CreateAccountView(viewModel: CreateAccountViewModel(interactor: interactor))
    }

    func addExerciseModelView(selectedExercises: Binding<[ExerciseTemplateModel]>) -> some View {
        AddExerciseModalView(
            viewModel: AddExerciseModalViewModel(
                interactor: interactor,
            ),
            selectedExercises: selectedExercises
        )
    }

    func profileGoalSection(path: Binding<[TabBarPathOption]>) -> some View {
        ProfileGoalSection(
            viewModel: ProfileGoalSectionViewModel(interactor: interactor),
            path: path
        )
    }

    func dayScheduleSheetView(date: Date, scheduledWorkouts: [ScheduledWorkout], onStartWorkout: @escaping (ScheduledWorkout) -> Void) -> some View {
        DayScheduleSheetView(
            viewModel: DayScheduleSheetViewModel(
                interactor: interactor,
                date: date,
                scheduledWorkouts: scheduledWorkouts,
                onStartWorkout: onStartWorkout
            )
        )
}

    // swiftlint:disable:next function_parameter_count
    func exerciseTrackerCardView(
        exercise: WorkoutExerciseModel,
        exerciseIndex: Int,
        isCurrentExercise: Bool,
        weightUnit: ExerciseWeightUnit,
        distanceUnit: ExerciseDistanceUnit,
        previousSetsByIndex: [Int: WorkoutSetModel],
        onSetUpdate: @escaping (WorkoutSetModel) -> Void,
        onAddSet: @escaping () -> Void,
        onDeleteSet: @escaping (String) -> Void,
        onHeaderLongPress: @escaping () -> Void,
        onNotesChange: @escaping (String) -> Void,
        onWeightUnitChange: @escaping (ExerciseWeightUnit) -> Void,
        onDistanceUnitChange: @escaping (ExerciseDistanceUnit) -> Void,
        restBeforeSecForSet: @escaping (String) -> Int?,
        onRestBeforeChange: @escaping (String, Int?) -> Void,
        onRequestRestPicker: @escaping (String, Int?) -> Void,
        getLatestExercise: @escaping () -> WorkoutExerciseModel?,
        getLatestExerciseIndex: @escaping () -> Int,
        getLatestIsCurrentExercise: @escaping () -> Bool,
        getLatestWeightUnit: @escaping () -> ExerciseWeightUnit,
        getLatestDistanceUnit: @escaping () -> ExerciseDistanceUnit,
        getLatestPreviousSets: @escaping () -> [Int: WorkoutSetModel],
        isExpanded: Binding<Bool>
    ) -> some View {
        ExerciseTrackerCardView(
            viewModel: ExerciseTrackerCardViewModel(
                interactor: interactor,
                exercise: exercise,
                exerciseIndex: exerciseIndex,
                isCurrentExercise: isCurrentExercise,
                weightUnit: weightUnit,
                distanceUnit: distanceUnit,
                previousSetsByIndex: previousSetsByIndex,
                onSetUpdate: onSetUpdate,
                onAddSet: onAddSet,
                onDeleteSet: onDeleteSet,
                onHeaderLongPress: onHeaderLongPress,
                onNotesChange: onNotesChange,
                onWeightUnitChange: onWeightUnitChange,
                onDistanceUnitChange: onDistanceUnitChange,
                restBeforeSecForSet: restBeforeSecForSet,
                onRestBeforeChange: onRestBeforeChange,
                onRequestRestPicker: onRequestRestPicker,
                getLatestExercise: getLatestExercise,
                getLatestExerciseIndex: getLatestExerciseIndex,
                getLatestIsCurrentExercise: getLatestIsCurrentExercise,
                getLatestWeightUnit: getLatestWeightUnit,
                getLatestDistanceUnit: getLatestDistanceUnit,
                getLatestPreviousSets: getLatestPreviousSets),
            isExpanded: isExpanded
            )
    }
}

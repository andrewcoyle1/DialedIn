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

    func appView() -> AnyView {
        AppView(
            viewModel: AppViewModel(interactor: interactor),
            adaptiveMainView: { self.adaptiveMainView() },
            onboardingWelcomeView: { self.onboardingWelcomeView() }
        )
        .any()
    }

    // MARK: Onboarding

    func onboardingWelcomeView() -> AnyView {
        OnboardingWelcomeView(
            viewModel: OnboardingWelcomeViewModel(interactor: interactor)
        )
        .any()
    }

    func onboardingIntroView(delegate: OnboardingIntroViewDelegate) -> AnyView {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    // MARK: Onboarding Auth

    func onboardingAuthOptionsView(delegate: AuthOptionsViewDelegate) -> AnyView {
        AuthOptionsView(
            viewModel: AuthOptionsViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingSignInView(delegate: SignInViewDelegate) -> AnyView {
        SignInView(
            viewModel: SignInViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingSignUpView(delegate: SignUpViewDelegate) -> AnyView {
        SignUpView(
            viewModel: SignUpViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingEmailVerificationView(delegate: EmailVerificationViewDelegate) -> AnyView {
        EmailVerificationView(
            viewModel: EmailVerificationViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    // MARK: Onboarding Subscriptions

    func onboardingSubscriptionView(delegate: OnboardingSubscriptionViewDelegate) -> AnyView {
        OnboardingSubscriptionView(
            viewModel: OnboardingSubscriptionViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingSubscriptionPlanView(delegate: OnboardingSubscriptionPlanViewDelegate) -> AnyView {
        OnboardingSubscriptionPlanView(
            viewModel: OnboardingSubscriptionPlanViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingCompleteAccountSetupView(delegate: OnboardingCompleteAccountSetupViewDelegate) -> AnyView {
        OnboardingCompleteAccountSetupView(
            viewModel: OnboardingCompleteAccountSetupViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingNamePhotoView(delegate: OnboardingNamePhotoViewDelegate) -> AnyView {
        OnboardingNamePhotoView(
            viewModel: OnboardingNamePhotoViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingGenderView(delegate: OnboardingGenderViewDelegate) -> AnyView {
        OnboardingGenderView(
            viewModel: OnboardingGenderViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingDateOfBirthView(delegate: OnboardingDateOfBirthViewDelegate) -> AnyView {
        OnboardingDateOfBirthView(
            viewModel: OnboardingDateOfBirthViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingHeightView(delegate: OnboardingHeightViewDelegate) -> AnyView {
        OnboardingHeightView(
            viewModel: OnboardingHeightViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingWeightView(delegate: OnboardingWeightViewDelegate) -> AnyView {
        OnboardingWeightView(
            viewModel: OnboardingWeightViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingExerciseFrequencyView(delegate: OnboardingExerciseFrequencyViewDelegate) -> AnyView {
        OnboardingExerciseFrequencyView(
            viewModel: OnboardingExerciseFrequencyViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingActivityView(delegate: OnboardingActivityViewDelegate) -> AnyView {
        OnboardingActivityView(
            viewModel: OnboardingActivityViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingCardioFitnessView(delegate: OnboardingCardioFitnessViewDelegate) -> AnyView {
        OnboardingCardioFitnessView(
            viewModel: OnboardingCardioFitnessViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingExpenditureView(delegate: OnboardingExpenditureViewDelegate) -> AnyView {
        OnboardingExpenditureView(
            viewModel: OnboardingExpenditureViewModel(interactor: interactor), 
            delegate: delegate
        )
        .any()
    }

    func onboardingHealthDataView(delegate: OnboardingHealthDataViewDelegate) -> AnyView {
        OnboardingHealthDataView(
            viewModel: OnboardingHealthDataViewModel(interactor: interactor), 
            delegate: delegate
        )
        .any()
    }

    func onboardingNotificationsView(delegate: OnboardingNotificationsViewDelegate) -> AnyView {
        OnboardingNotificationsView(
            viewModel: OnboardingNotificationsViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingHealthDisclaimerView(delegate: OnboardingHealthDisclaimerViewDelegate) -> AnyView {
        OnboardingHealthDisclaimerView(
            viewModel: OnboardingHealthDisclaimerViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    // MARK: Onboarding Goal Setting

    func onboardingGoalSettingView(delegate: OnboardingGoalSettingViewDelegate) -> AnyView {
        OnboardingGoalSettingView(
            viewModel: OnboardingGoalSettingViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingOverarchingObjectiveView(delegate: OnboardingOverarchingObjectiveViewDelegate) -> AnyView {
        OnboardingOverarchingObjectiveView(
            viewModel: OnboardingOverarchingObjectiveViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingTargetWeightView(delegate: OnboardingTargetWeightViewDelegate) -> AnyView {
        OnboardingTargetWeightView(
            viewModel: OnboardingTargetWeightViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingWeightRateView(delegate: OnboardingWeightRateViewDelegate) -> AnyView {
        OnboardingWeightRateView(
            viewModel: OnboardingWeightRateViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingGoalSummaryView(delegate: OnboardingGoalSummaryViewDelegate) -> AnyView {
        OnboardingGoalSummaryView(
            viewModel: OnboardingGoalSummaryViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    // MARK: Customise Program

    func onboardingCustomisingProgramView(delegate: OnboardingCustomisingProgramViewDelegate) -> AnyView {
        OnboardingCustomisingProgramView(
            viewModel: OnboardingCustomisingProgramViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceViewDelegate) -> AnyView {
        OnboardingTrainingExperienceView(
            viewModel: OnboardingTrainingExperienceViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingDaysPerWeekView(delegate: OnboardingTrainingDaysPerWeekViewDelegate) -> AnyView {
        OnboardingTrainingDaysPerWeekView(
            viewModel: OnboardingTrainingDaysPerWeekViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingSplitView(delegate: OnboardingTrainingSplitViewDelegate) -> AnyView {
        OnboardingTrainingSplitView(
            viewModel: OnboardingTrainingSplitViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingScheduleView(delegate: OnboardingTrainingScheduleViewDelegate) -> AnyView {
        OnboardingTrainingScheduleView(
            viewModel: OnboardingTrainingScheduleViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingEquipmentView(delegate: OnboardingTrainingEquipmentViewDelegate) -> AnyView {
        OnboardingTrainingEquipmentView(
            viewModel: OnboardingTrainingEquipmentViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingReviewView(delegate: OnboardingTrainingReviewViewDelegate) -> AnyView {
        OnboardingTrainingReviewView(
            viewModel: OnboardingTrainingReviewViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingPreferredDietView(delegate: OnboardingPreferredDietViewDelegate) -> AnyView {
        OnboardingPreferredDietView(
            viewModel: OnboardingPreferredDietViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingCalorieFloorView(delegate: OnboardingCalorieFloorViewDelegate) -> AnyView {
        OnboardingCalorieFloorView(
            viewModel: OnboardingCalorieFloorViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingTypeView(delegate: OnboardingTrainingTypeViewDelegate) -> AnyView {
        OnboardingTrainingTypeView(
            viewModel: OnboardingTrainingTypeViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingCalorieDistributionView(delegate: OnboardingCalorieDistributionViewDelegate) -> AnyView {
        OnboardingCalorieDistributionView(
            viewModel: OnboardingCalorieDistributionViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingProteinIntakeView(delegate: OnboardingProteinIntakeViewDelegate) -> AnyView {
        OnboardingProteinIntakeView(
            viewModel: OnboardingProteinIntakeViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingDietPlanView(delegate: OnboardingDietPlanViewDelegate) -> AnyView {
        OnboardingDietPlanView(
            viewModel: OnboardingDietPlanViewModel(
                interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func onboardingCompletedView(delegate: OnboardingCompletedViewDelegate, devSettingsView: () -> AnyView) -> AnyView {
        OnboardingCompletedView(
            viewModel: OnboardingCompletedViewModel(
                interactor: interactor),
            delegate: delegate,
            devSettingsView: { self.devSettingsView() }
        )
        .any()
    }

    // MARK: Main App
    func adaptiveMainView() -> AnyView {
        AdaptiveMainView(
            viewModel: AdaptiveMainViewModel(interactor: interactor),
            tabBarView: { delegate in
                self.tabBarView(delegate: delegate)
            },
            splitViewContainer: { delegate in
                self.splitViewContainer(delegate: delegate)
            }
        )
        .any()
    }

    func tabBarView(delegate: TabBarViewDelegate) -> AnyView {
        TabBarView(
            viewModel: TabBarViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func splitViewContainer(delegate: SplitViewDelegate) -> AnyView {
        SplitViewContainer(
            viewModel: SplitViewContainerViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func exerciseTemplateDetailView(delegate: ExerciseTemplateDetailViewDelegate) -> AnyView {
        ExerciseTemplateDetailView(
            viewModel: ExerciseTemplateDetailViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func tabViewAccessoryView(delegate: TabViewAccessoryViewDelegate) -> AnyView {
        TabViewAccessoryView(
            viewModel: TabViewAccessoryViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func workoutTrackerView(delegate: WorkoutTrackerViewDelegate) -> AnyView {
        WorkoutTrackerView(
            viewModel: WorkoutTrackerViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func ingredientDetailView(delegate: IngredientDetailViewDelegate) -> AnyView {
        IngredientDetailView(
            viewModel: IngredientDetailViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func exerciseTemplateListView(delegate: ExerciseTemplateListViewDelegate) -> AnyView {
        ExerciseTemplateListView(
            viewModel: ExerciseTemplateListViewModel.create(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func workoutTemplateListView(delegate: WorkoutTemplateListViewDelegate) -> AnyView {
        WorkoutTemplateListView(
            viewModel: WorkoutTemplateListViewModel.create(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func workoutTemplateDetailView(delegate: WorkoutTemplateDetailViewDelegate) -> AnyView {
        WorkoutTemplateDetailView(
            viewModel: WorkoutTemplateDetailViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func workoutSessionDetailView(delegate: WorkoutSessionDetailViewDelegate) -> AnyView {
        WorkoutSessionDetailView(
            viewModel: WorkoutSessionDetailViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func programView(delegate: ProgramViewDelegate) -> AnyView {
        ProgramView(
            viewModel: ProgramViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func devSettingsView() -> AnyView {
        DevSettingsView(
            viewModel: DevSettingsViewModel(interactor: interactor)
        )
        .any()
    }

    func workoutStartView(delegate: WorkoutStartViewDelegate) -> AnyView {
        WorkoutStartView(
            viewModel: WorkoutStartViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func dashboardView(delegate: DashboardViewDelegate) -> AnyView {
        DashboardView(
            viewModel: DashboardViewModel(interactor: interactor),
            delegate: delegate,
            devSettingsView: { self.devSettingsView() },
            notificationsView: { self.notificationsView() },
            nutritionTargetChartView: { self.nutritionTargetChartView() }
        )
        .any()
    }

    func createIngredientView() -> AnyView {
        CreateIngredientView(
            viewModel: CreateIngredientViewModel(interactor: interactor)
        )
        .any()
    }

    func addIngredientModalView(delegate: AddIngredientModalViewDelegate) -> AnyView {
        AddIngredientModalView(
            viewModel: AddIngredientModalViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func createRecipeView() -> AnyView {
        CreateRecipeView(
            viewModel: CreateRecipeViewModel(interactor: interactor)
        )
        .any()
    }

    func mealLogView(delegate: MealLogViewDelegate) -> AnyView {
        MealLogView(
            viewModel: MealLogViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func recipesView(delegate: RecipesViewDelegate) -> AnyView {
        RecipesView(
            viewModel: RecipesViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func ingredientsView(delegate: IngredientsViewDelegate) -> AnyView {
        IngredientsView(
            viewModel: IngredientsViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func nutritionView(delegate: NutritionViewDelegate) -> AnyView {
        NutritionView(
            viewModel: NutritionViewModel(interactor: interactor),
            delegate: delegate,
            devSettingsView: { self.devSettingsView() },
            notificationsView: { self.notificationsView() },
            createIngredientView: { self.createIngredientView() },
            createRecipeView: { self.createRecipeView() },
            mealLogView: { delegate in
                self.mealLogView(delegate: delegate)
            },
            recipesView: { delegate in
                self.recipesView(delegate: delegate)
            },
            ingredientsView: { delegate in
                self.ingredientsView(delegate: delegate)
            },
            ingredientDetailView: { delegate in
                self.ingredientDetailView(delegate: delegate)
            },
            recipeDetailView: { delegate in
                self.recipeDetailView(delegate: delegate)
            }
        )
        .any()
    }

    func nutritionLibraryPickerView(delegate: NutritionLibraryPickerViewDelegate) -> AnyView {
        NutritionLibraryPickerView(
            viewModel: NutritionLibraryPickerViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func addMealSheet(delegate: AddMealSheetDelegate) -> AnyView {
        AddMealSheet(
            viewModel: AddMealSheetViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func nutritionTargetChartView() -> AnyView {
        NutritionTargetChartView(
            viewModel: NutritionTargetChartViewModel(interactor: interactor)
        )
        .any()
    }

    func workoutsView(delegate: WorkoutsViewDelegate) -> AnyView {
        WorkoutsView(
            viewModel: WorkoutsViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func workoutHistoryView(delegate: WorkoutHistoryViewDelegate) -> AnyView {
        WorkoutHistoryView(
            viewModel: WorkoutHistoryViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func createWorkoutView(delegate: CreateWorkoutViewDelegate) -> AnyView {
        CreateWorkoutView(
            viewModel: CreateWorkoutViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func createExerciseView() -> AnyView {
        CreateExerciseView(
            viewModel: CreateExerciseViewModel(interactor: interactor)
        )
        .any()
    }

    func addGoalView(delegate: AddGoalViewDelegate) -> AnyView {
        AddGoalView(
            viewModel: AddGoalViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func workoutSummaryCardView(delegate: WorkoutSummaryCardViewDelegate) -> AnyView {
        WorkoutSummaryCardView(
            viewModel: WorkoutSummaryCardViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func todaysWorkoutCardView(delegate: TodaysWorkoutCardViewDelegate) -> AnyView {
        TodaysWorkoutCardView(
            viewModel: TodaysWorkoutCardViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func scheduledWorkoutRowView(delegate: ScheduledWorkoutRowViewDelegate) -> AnyView {
        ScheduledWorkoutRowView(
            viewModel: ScheduledWorkoutRowViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func programRowView(delegate: ProgramRowViewDelegate) -> AnyView {
        ProgramRowView(
            viewModel: ProgramRowViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func workoutCalendarView(delegate: WorkoutCalendarViewDelegate) -> AnyView {
        WorkoutCalendarView(
            viewModel: WorkoutCalendarViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func editableExerciseCardWrapper(delegate: EditableExerciseCardWrapperDelegate) -> AnyView {
        EditableExerciseCardWrapper(
            delegate: delegate,
            interactor: interactor
        )
        .any()
    }

    func exercisesView(delegate: ExercisesViewDelegate) -> AnyView {
        ExercisesView(
            viewModel: ExercisesViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func programManagementView(delegate: ProgramManagementViewDelegate) -> AnyView {
        ProgramManagementView(
            viewModel: ProgramManagementViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func trainingView(delegate: TrainingViewDelegate) -> AnyView {
        TrainingView(
            viewModel: TrainingViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func progressDashboardView() -> AnyView {
        ProgressDashboardView(
            viewModel: ProgressDashboardViewModel(interactor: interactor)
        )
        .any()
    }

    func strengthProgressView() -> AnyView {
        StrengthProgressView(
            viewModel: StrengthProgressViewModel(interactor: interactor)
        )
        .any()
    }

    func workoutHeatmapView() -> AnyView {
        WorkoutHeatmapView(
            viewModel: WorkoutHeatmapViewModel(interactor: interactor)
        )
        .any()
    }

    func notificationsView() -> AnyView {
        NotificationsView(
            viewModel: NotificationsViewModel(interactor: interactor)
        )
        .any()
    }

    func programGoalsView(delegate: ProgramGoalsViewDelegate) -> AnyView {
        ProgramGoalsView(
            viewModel: ProgramGoalsViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func programScheduleView(delegate: ProgramScheduleViewDelegate) -> AnyView {
        ProgramScheduleView(
            viewModel: ProgramScheduleViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func mealDetailView(delegate: MealDetailViewDelegate) -> AnyView {
        MealDetailView(
            viewModel: MealDetailViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func profileGoalsDetailView() -> AnyView {
        ProfileGoalsDetailView(
            viewModel: ProfileGoalsDetailViewModel(interactor: interactor)
        )
        .any()
    }

    func profileEditView() -> AnyView {
        ProfileEditView(
            viewModel: ProfileEditViewModel(interactor: interactor)
        )
        .any()
    }

    func profileNutritionDetailView() -> AnyView {
        ProfileNutritionDetailView(
            viewModel: ProfileNutritionDetailViewModel(interactor: interactor)
        )
        .any()
    }

    func profilePhysicalStatsView() -> AnyView {
        ProfilePhysicalStatsView(
            viewModel: ProfilePhysicalStatsViewModel(interactor: interactor)
        )
        .any()
    }

    func settingsView(delegate: SettingsViewDelegate) -> AnyView {
        SettingsView(
            viewModel: SettingsViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func ingredientTemplateListView(delegate: IngredientTemplateListViewDelegate) -> AnyView {
        IngredientTemplateListView(
            interactor: interactor,
            delegate: delegate
        )
        .any()
    }

    func ingredientAmountView(delegate: IngredientAmountViewDelegate) -> AnyView {
        IngredientAmountView(
            viewModel: IngredientAmountViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func goalRow(delegate: GoalRowDelegate) -> AnyView {
        GoalRow(
            viewModel: GoalRowViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func programTemplatePickerView(delegate: ProgramTemplatePickerViewDelegate) -> AnyView {
        ProgramTemplatePickerView(
            viewModel: ProgramTemplatePickerViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func editProgramView(delegate: EditProgramViewDelegate) -> AnyView {
        EditProgramView(
            viewModel: EditProgramViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func enhancedScheduleView(delegate: EnhancedScheduleViewDelegate) -> AnyView {
        EnhancedScheduleView(
            viewModel: EnhancedScheduleViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func logWeightView() -> AnyView {
        LogWeightView(
            viewModel: LogWeightViewModel(interactor: interactor)
        )
        .any()
    }

    func profileHeaderView(delegate: ProfileHeaderViewDelegate) -> AnyView {
        ProfileHeaderView(
            viewModel: ProfileHeaderViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func profilePhysicalMetricsView(delegate: ProfilePhysicalMetricsViewDelegate) -> AnyView {
        ProfilePhysicalMetricsView(
            viewModel: ProfilePhysicalMetricsViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func profileGoalSection(delegate: ProfileGoalSectionDelegate) -> AnyView {
        ProfileGoalSection(
            viewModel: ProfileGoalSectionViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func profileNutritionPlanView(delegate: ProfileNutritionPlanViewDelegate) -> AnyView {
        ProfileNutritionPlanView(
            viewModel: ProfileNutritionPlanViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func profilePreferencesView(delegate: ProfilePreferencesViewDelegate) -> AnyView {
        ProfilePreferencesView(
            viewModel: ProfilePreferencesViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func profileMyTemplatesView(delegate: ProfileMyTemplatesViewDelegate) -> AnyView {
        ProfileMyTemplatesView(
            viewModel: ProfileMyTemplatesViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func recipeDetailView(delegate: RecipeDetailViewDelegate) -> AnyView {
        RecipeDetailView(
            viewModel: RecipeDetailViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func recipeTemplateListView(delegate: RecipeTemplateListViewDelegate) -> AnyView {
        RecipeTemplateListView(
            interactor: interactor,
            delegate: delegate
        )
        .any()
    }

    func customProgramBuilderView(delegate: CustomProgramBuilderViewDelegate) -> AnyView {
        CustomProgramBuilderView(
            viewModel: CustomProgramBuilderViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func programPreviewView(delegate: ProgramPreviewViewDelegate) -> AnyView {
        ProgramPreviewView(
            viewModel: ProgramPreviewViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func manageSubscriptionView() -> AnyView {
        ManageSubscriptionView()
            .any()
    }

    func recipeAmountView(delegate: RecipeAmountViewDelegate) -> AnyView {
        RecipeAmountView(
            viewModel: RecipeAmountViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func programStartConfigView(delegate: ProgramStartConfigViewDelegate) -> AnyView {
        ProgramStartConfigView(
            viewModel: ProgramStartConfigViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func volumeChartsView() -> AnyView {
         VolumeChartsView(
            viewModel: VolumeChartsViewModel(interactor: interactor)
         )
         .any()
    }

    func workoutPickerSheet(delegate: WorkoutPickerSheetDelegate) -> AnyView {
        WorkoutPickerSheet(
            interactor: interactor,
            delegate: delegate
        )
        .any()
    }

    func trendSummarySection(delegate: TrendSummarySectionDelegate) -> AnyView {
        TrendSummarySection(
            viewModel: TrendSummarySectionViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func setTrackerRowView(delegate: SetTrackerRowViewDelegate) -> AnyView {
        SetTrackerRowView(
            viewModel: SetTrackerRowViewModel(interactor: interactor),
            delegate: delegate,
        )
        .any()
    }

    func profileView(delegate: ProfileViewDelegate) -> AnyView {
        ProfileView(
            viewModel: ProfileViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func createAccountView() -> AnyView {
        CreateAccountView(
            viewModel: CreateAccountViewModel(interactor: interactor)
        )
        .any()
    }

    func addExerciseModalView(delegate: AddExerciseModalViewDelegate) -> AnyView {
        AddExerciseModalView(
            viewModel: AddExerciseModalViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func dayScheduleSheetView(delegate: DayScheduleSheetViewDelegate) -> AnyView {
        DayScheduleSheetView(
            viewModel: DayScheduleSheetViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func exerciseTrackerCardView(delegate: ExerciseTrackerCardViewDelegate) -> AnyView {
        ExerciseTrackerCardView(
            delegate: delegate,
            interactor: interactor
        )
        .any()
    }
}

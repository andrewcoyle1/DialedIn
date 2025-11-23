//
//  CoreRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/11/2025.
//

import SwiftUI
import CustomRouting

@MainActor
struct CoreRouter {

    private let router: Router
    private let builder: CoreBuilder

    init(router: Router, builder: CoreBuilder) {
        self.router = router
        self.builder = builder
    }

    func showOnboardingIntroView() {
        router.showScreen(.push) { router in
            builder.onboardingIntroView(router: router)
        }
    }

    func showAuthOptionsView() {
        router.showScreen(.push) { router in
            builder.onboardingAuthOptionsView(router: router)
        }
    }

    func showSignInView() {
        router.showScreen(.push) { router in
            builder.onboardingSignInView(router: router)
        }
    }

    func showSignUpView() {
        router.showScreen(.push) { router in
            builder.onboardingSignUpView(router: router)
        }
    }

    func showEmailVerificationView() {
        router.showScreen(.push) { router in
            builder.onboardingEmailVerificationView(router: router)
        }
    }

    func showSubscriptionView() {
        router.showScreen(.push) { router in
            builder.onboardingSubscriptionView(router: router)
        }
    }

    func showSubscriptionPlanView() {
        router.showScreen(.push) { router in
            builder.onboardingSubscriptionPlanView(router: router)
        }
    }

    func showOnboardingCompleteAccountSetupView() {
        router.showScreen(.push) { router in
            builder.onboardingCompleteAccountSetupView(router: router)
        }
    }

    func showOnboardingNamePhotoView() {
        router.showScreen(.push) { router in
            builder.onboardingNamePhotoView(router: router)
        }
    }

    func showOnboardingGenderView() {
        router.showScreen(.push) { router in
            builder.onboardingGenderView(router: router)
        }
    }

    func showOnboardingDateOfBirthView(delegate: OnboardingDateOfBirthViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingDateOfBirthView(router: router, delegate: delegate)
        }
    }

    func showOnboardingHeightView(delegate: OnboardingHeightViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingHeightView(router: router, delegate: delegate)
        }
    }

    func showOnboardingWeightView(delegate: OnboardingWeightViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingWeightView(router: router, delegate: delegate)
        }
    }

    func showOnboardingExerciseFrequencyView(delegate: OnboardingExerciseFrequencyViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingExerciseFrequencyView(router: router, delegate: delegate)
        }
    }

    func showOnboardingActivityView(delegate: OnboardingActivityViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingActivityView(router: router, delegate: delegate)
        }
    }

    func showOnboardingCardioFitnessView(delegate: OnboardingCardioFitnessViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCardioFitnessView(router: router, delegate: delegate)
        }
    }

    func showOnboardingExpenditureView(delegate: OnboardingExpenditureViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingExpenditureView(router: router, delegate: delegate)
        }
    }

    func showOnboardingHealthDataView() {
        router.showScreen(.push) { router in
            builder.onboardingHealthDataView(router: router)
        }
    }

    func showOnboardingNotificationsView() {
        router.showScreen(.push) { router in
            builder.onboardingNotificationsView(router: router)
        }
    }

    func showOnboardingHealthDisclaimerView() {
        router.showScreen(.push) { router in
            builder.onboardingHealthDisclaimerView(router: router)
        }
    }

    func showOnboardingGoalSettingView() {
        router.showScreen(.push) { router in
            builder.onboardingGoalSettingView(router: router)
        }
    }

    func showOnboardingOverarchingObjectiveView() {
        router.showScreen(.push) { router in
            builder.onboardingOverarchingObjectiveView(router: router)
        }
    }

    func showOnboardingTargetWeightView(delegate: OnboardingTargetWeightViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTargetWeightView(router: router, delegate: delegate)
        }
    }

    func showOnboardingWeightRateView(delegate: OnboardingWeightRateViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingWeightRateView(router: router, delegate: delegate)
        }
    }

    func showOnboardingGoalSummaryView(delegate: OnboardingGoalSummaryViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingGoalSummaryView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingProgramView() {
        router.showScreen(.push) { router in
            builder.onboardingTrainingProgramView(router: router)
        }
    }

    func showOnboardingCustomisingProgramView() {
        router.showScreen(.push) { router in
            builder.onboardingCustomisingProgramView(router: router)
        }
    }

    func showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingExperienceView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingDaysPerWeekView(delegate: OnboardingTrainingDaysPerWeekViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingDaysPerWeekView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingSplitView(delegate: OnboardingTrainingSplitViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingSplitView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingScheduleView(delegate: OnboardingTrainingScheduleViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingScheduleView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingEquipmentView(delegate: OnboardingTrainingEquipmentViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingEquipmentView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingReviewView(delegate: OnboardingTrainingReviewViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingReviewView(router: router, delegate: delegate)
        }
    }

    func showOnboardingPreferredDietView() {
        router.showScreen(.push) { router in
            builder.onboardingPreferredDietView(router: router)
        }
    }

    func showOnboardingCalorieFloorView(delegate: OnboardingCalorieFloorViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCalorieFloorView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingTypeView(delegate: OnboardingTrainingTypeViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingTypeView(router: router, delegate: delegate)
        }
    }

    func showOnboardingCalorieDistributionView(delegate: OnboardingCalorieDistributionViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCalorieDistributionView(router: router, delegate: delegate)
        }
    }

    func showOnboardingProteinIntakeView(delegate: OnboardingProteinIntakeViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingProteinIntakeView(router: router, delegate: delegate)
        }
    }

    func showOnboardingDietPlanView(delegate: OnboardingDietPlanViewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingDietPlanView(router: router, delegate: delegate)
        }
    }

    func showOnboardingCompletedView() {
        router.showScreen(.push) { router in
            builder.onboardingCompletedView(router: router)
        }
    }

    // MARK: MAIN APP

    func showDevSettingsView() {
        router.showScreen(.fullScreenCover) { _ in
            builder.devSettingsView()
        }
    }

    func showNotificationsView() {
        router.showScreen(.sheet) { router in
            builder.notificationsView(router: router)
        }
    }

    func showCreateExerciseView() {
        router.showScreen(.fullScreenCover) { router in
            builder.createExerciseView(router: router)
        }
    }

    func showAddExercisesView(delegate: AddExerciseModalViewDelegate) {
        router.showScreen(.sheet) { router in
            builder.addExerciseModalView(router: router, delegate: delegate)
        }
    }

    func showCreateWorkoutView(delegate: CreateWorkoutViewDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.createWorkoutView(router: router, delegate: delegate)
        }
    }

    func showWorkoutStartView(delegate: WorkoutStartViewDelegate) {
        router.showScreen(.sheet) { router in
            builder.workoutStartView(router: router, delegate: delegate)
        }
    }

    func showWorkoutTrackerView(delegate: WorkoutTrackerViewDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.workoutTrackerView(router: router, delegate: delegate)
        }
    }

    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailViewDelegate) {
        router.showScreen(.sheet) { router in
            builder.workoutSessionDetailView(router: router, delegate: delegate)
        }
    }

    func showCreateIngredientView() {
        router.showScreen(.sheet) { router in
            builder.createIngredientView(router: router)
        }
    }

    func showCreateRecipeView() {
        router.showScreen(.sheet) { router in
            builder.createRecipeView(router: router)
        }
    }

    func showAddIngredientView(delegate: AddIngredientModalViewDelegate) {
        router.showScreen(.sheet) { _ in
            builder.addIngredientModalView(delegate: delegate)
        }
    }

    func showIngredientDetailView(delegate: IngredientDetailViewDelegate) {
        router.showScreen(.push) { router in
            builder.ingredientDetailView(router: router, delegate: delegate)
        }
    }

    func showRecipeDetailView(delegate: RecipeDetailViewDelegate) {
        router.showScreen(.push) { router in
            builder.recipeDetailView(router: router, delegate: delegate)
        }
    }

    func showRecipeAmountView(delegate: RecipeAmountViewDelegate) {
        router.showScreen(.push) { router in
            builder.recipeAmountView(delegate: delegate)
        }
    }

    func showStartRecipeView(delegate: RecipeStartViewDelegate) {
        router.showScreen(.push) { router in
            builder.recipeStartView(router: router, delegate: delegate)
        }
    }

    func showNutritionLibraryPickerView(delegate: NutritionLibraryPickerViewDelegate) {
        router.showScreen(.sheet) { router in
            builder.nutritionLibraryPickerView(router: router, delegate: delegate)
        }
    }

    func showIngredientAmountView(delegate: IngredientAmountViewDelegate) {
        router.showScreen(.push) { router in
            builder.ingredientAmountView(router: router, delegate: delegate)
        }
    }

    func showProgramGoalsView(delegate: ProgramGoalsViewDelegate) {
        router.showScreen(.push) { router in
            builder.programGoalsView(router: router, delegate: delegate)
        }
    }
    func showProgramScheduleView(delegate: ProgramScheduleViewDelegate) {
        router.showScreen(.push) { router in
            builder.programScheduleView(router: router, delegate: delegate)
        }
    }

    func showAddGoalView(delegate: AddGoalViewDelegate) {
        router.showScreen(.push) { router in
            builder.addGoalView(router: router, delegate: delegate)
        }
    }
    func showSettingsView() {
        router.showScreen(.push) { router in
            builder.settingsView(router: router)
        }
    }

    func showManageSubscriptionView() {
        router.showScreen(.push) { _ in
            builder.manageSubscriptionView()
        }
    }

    func showCreateAccountView() {
        router.showScreen(.fullScreenCover) { router in
            builder.createAccountView(router: router)
        }
    }

    func showAddMealView(delegate: AddMealSheetDelegate) {
        router.showScreen(.push) { router in
            builder.addMealSheet(router: router, delegate: delegate)
        }
    }

    func showProgramManagementView() {
        router.showScreen(.sheet) { router in
            builder.programManagementView(router: router)
        }
    }

    func showProgressDashboardView() {
        router.showScreen(.sheet) { _ in
            builder.progressDashboardView()
        }
    }

    func showStrengthProgressView() {
        router.showScreen(.sheet) { _ in
            builder.strengthProgressView()
        }
    }

    func showWorkoutHeatmapView() {
        router.showScreen(.sheet) { _ in
            builder.workoutHeatmapView()
        }
    }

    func showProgramPreviewView(delegate: ProgramPreviewViewDelegate) {
        router.showScreen(.push) { router in
            builder.programPreviewView(delegate: delegate)
        }
    }

    func showPhysicalStatsView() {
        router.showScreen(.push) { router in
            builder.profilePhysicalStatsView(router: router)
        }
    }

    func showProfileGoalsView() {
        router.showScreen(.push) { router in
            builder.profileGoalsDetailView(router: router)
        }
    }

    func showProgramStartConfigView(delegate: ProgramStartConfigViewDelegate) {
        router.showScreen(.sheet) { router in
            builder.programStartConfigView(router: router, delegate: delegate)
        }
    }

    func showExerciseTemplateListView(delegate: ExerciseTemplateListViewDelegate) {
        router.showScreen(.push) { router in
            builder.exerciseTemplateListView(router: router, delegate: delegate)
        }
    }

    func showWorkoutTemplateListView(delegate: WorkoutTemplateListViewDelegate) {
        router.showScreen(.push) { router in
            builder.workoutTemplateListView(router: router, delegate: delegate)
        }
    }

    func showIngredientTemplateListView(delegate: IngredientTemplateListViewDelegate) {
        router.showScreen(.push) { router in
            builder.ingredientTemplateListView(router: router, delegate: delegate)
        }
    }

    func showRecipeTemplateListView(delegate: RecipeTemplateListViewDelegate) {
        router.showScreen(.push) { router in
            builder.recipeTemplateListView(router: router, delegate: delegate)
        }
    }

    func showProfileEditView() {
        router.showScreen(.push) { router in
            builder.profileEditView(router: router)
        }
    }

    func showProfileNutritionDetailView() {
        router.showScreen(.push) { router in
            builder.profileNutritionDetailView(router: router)
        }
    }

    func showMealDetailView(delegate: MealDetailViewDelegate) {
        router.showScreen(.sheet) { router in
            builder.mealDetailView(delegate: delegate)
        }
    }

    func showCustomProgramBuilderView() {
        router.showScreen(.sheet) { router in
            builder.customProgramBuilderView(router: router)
        }
    }

    func showLogWeightView() {
        router.showScreen(.push) { router in
            builder.logWeightView()
        }
    }

    func dismissScreen() {
        router.dismissScreen()
    }

    // MARK: Alerts

    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }

    func showAlert(alert: CustomRouting.AlertType, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: buttons)
    }

    func showSimpleAlert(title: String, subtitle: String?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: nil)
    }
}

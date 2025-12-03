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

    func showOnboardingDateOfBirthView(delegate: OnboardingDateOfBirthDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingDateOfBirthView(router: router, delegate: delegate)
        }
    }

    func showOnboardingHeightView(delegate: OnboardingHeightDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingHeightView(router: router, delegate: delegate)
        }
    }

    func showOnboardingWeightView(delegate: OnboardingWeightDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingWeightView(router: router, delegate: delegate)
        }
    }

    func showOnboardingExerciseFrequencyView(delegate: OnboardingExerciseFrequencyDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingExerciseFrequencyView(router: router, delegate: delegate)
        }
    }

    func showOnboardingActivityView(delegate: OnboardingActivityDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingActivityView(router: router, delegate: delegate)
        }
    }

    func showOnboardingCardioFitnessView(delegate: OnboardingCardioFitnessDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCardioFitnessView(router: router, delegate: delegate)
        }
    }

    func showOnboardingExpenditureView(delegate: OnboardingExpenditureDelegate) {
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

    func showOnboardingTargetWeightView(delegate: OnboardingTargetWeightDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTargetWeightView(router: router, delegate: delegate)
        }
    }

    func showOnboardingWeightRateView(delegate: OnboardingWeightRateDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingWeightRateView(router: router, delegate: delegate)
        }
    }

    func showOnboardingGoalSummaryView(delegate: OnboardingGoalSummaryDelegate) {
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

    func showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingExperienceView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingDaysPerWeekView(delegate: OnboardingTrainingDaysPerWeekDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingDaysPerWeekView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingSplitView(delegate: OnboardingTrainingSplitDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingSplitView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingScheduleView(delegate: OnboardingTrainingScheduleDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingScheduleView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingEquipmentView(delegate: OnboardingTrainingEquipmentDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingEquipmentView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingReviewView(delegate: OnboardingTrainingReviewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingReviewView(router: router, delegate: delegate)
        }
    }

    func showOnboardingPreferredDietView() {
        router.showScreen(.push) { router in
            builder.onboardingPreferredDietView(router: router)
        }
    }

    func showOnboardingCalorieFloorView(delegate: OnboardingCalorieFloorDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCalorieFloorView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingTypeView(delegate: OnboardingTrainingTypeDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingTypeView(router: router, delegate: delegate)
        }
    }

    func showOnboardingCalorieDistributionView(delegate: OnboardingCalorieDistributionDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCalorieDistributionView(router: router, delegate: delegate)
        }
    }

    func showOnboardingProteinIntakeView(delegate: OnboardingProteinIntakeDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingProteinIntakeView(router: router, delegate: delegate)
        }
    }

    func showOnboardingDietPlanView(delegate: OnboardingDietPlanDelegate) {
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
        router.showScreen(.fullScreenCover) { router in
            builder.devSettingsView(router: router)
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

    func showAddExercisesView(delegate: AddExerciseModalDelegate) {
        router.showScreen(.sheet) { router in
            builder.addExerciseModalView(router: router, delegate: delegate)
        }
    }
    
    func showProgramTemplatePickerView() {
        router.showScreen(.push) { router in
            builder.programTemplatePickerView(router: router)
        }
    }

    func showCreateWorkoutView(delegate: CreateWorkoutDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.createWorkoutView(router: router, delegate: delegate)
        }
    }

    func showWorkoutStartView(delegate: WorkoutStartDelegate) {
        router.showScreen(.sheet) { router in
            builder.workoutStartView(router: router, delegate: delegate)
        }
    }

    func showWorkoutTrackerView(delegate: WorkoutTrackerDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.workoutTrackerView(router: router, delegate: delegate)
        }
    }
    
    func showWorkoutsView() {
        router.showScreen(.push) { router in
            builder.workoutsView(router: router)
        }
    }
    
    func showExercisesView() {
        router.showScreen(.push) { router in
            builder.exercisesView(router: router)
        }
    }
    
    func showWorkoutHistoryView() {
        router.showScreen(.push) { router in
            builder.workoutHistoryView(router: router)
        }
    }
    
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate) {
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

    func showAddIngredientView(delegate: AddIngredientModalDelegate) {
        router.showScreen(.sheet) { router in
            builder.addIngredientModalView(router: router, delegate: delegate)
        }
    }

    func showIngredientDetailView(delegate: IngredientDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.ingredientDetailView(router: router, delegate: delegate)
        }
    }

    func showRecipeDetailView(delegate: RecipeDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.recipeDetailView(router: router, delegate: delegate)
        }
    }

    func showRecipeAmountView(delegate: RecipeAmountDelegate) {
        router.showScreen(.push) { router in
            builder.recipeAmountView(router: router, delegate: delegate)
        }
    }

    func showStartRecipeView(delegate: RecipeStartDelegate) {
        router.showScreen(.push) { router in
            builder.recipeStartView(router: router, delegate: delegate)
        }
    }

    func showNutritionLibraryPickerView(delegate: NutritionLibraryPickerDelegate) {
        router.showScreen(.sheet) { router in
            builder.nutritionLibraryPickerView(router: router, delegate: delegate)
        }
    }

    func showWorkoutPickerView(delegate: WorkoutPickerDelegate) {
        router.showScreen(.sheet) { router in
            builder.workoutPickerSheet(router: router, delegate: delegate)
        }
    }

    func showIngredientAmountView(delegate: IngredientAmountDelegate) {
        router.showScreen(.push) { router in
            builder.ingredientAmountView(router: router, delegate: delegate)
        }
    }

    func showProgramGoalsView(delegate: ProgramGoalsDelegate) {
        router.showScreen(.push) { router in
            builder.programGoalsView(router: router, delegate: delegate)
        }
    }
    func showProgramScheduleView(delegate: ProgramScheduleDelegate) {
        router.showScreen(.push) { router in
            builder.programScheduleView(router: router, delegate: delegate)
        }
    }

    func showAddGoalView(delegate: AddGoalDelegate) {
        router.showScreen(.push) { router in
            builder.addGoalView(router: router, delegate: delegate)
        }
    }
    func showSettingsView() {
        router.showScreen(.push) { router in
            builder.settingsView(router: router)
        }
    }
    
    func showManageSubscriptionView(delegate: ManageSubscriptionDelegate) {
        router.showScreen(.push) { router in
            builder.manageSubscriptionView(router: router, delegate: delegate)
        }
    }

    func showCreateAccountView() {
        router.showScreen(.fullScreenCover) { router in
            builder.createAccountView(router: router)
        }
    }

    func showAddMealView(delegate: AddMealDelegate) {
        router.showScreen(.push) { router in
            builder.addMealView(router: router, delegate: delegate)
        }
    }

    func showProgramManagementView() {
        router.showScreen(.fullScreenCover) { router in
            builder.programManagementView(router: router)
        }
    }

    func showProgressDashboardView() {
        router.showScreen(.sheet) { router in
            builder.progressDashboardView(router: router)
        }
    }

    func showStrengthProgressView() {
        router.showScreen(.sheet) { router in
            builder.strengthProgressView(router: router)
        }
    }

    func showCopyWeekPickerView(delegate: CopyWeekPickerDelegate) {
        router.showScreen(.sheet) { router in
            builder.copyWeekPickerView(router: router, delegate: delegate)
        }
    }

    func showWorkoutHeatmapView() {
        router.showScreen(.sheet) { router in
            builder.workoutHeatmapView(router: router)
        }
    }

    func showProgramPreviewView(delegate: ProgramPreviewDelegate) {
        router.showScreen(.push) { router in
            builder.programPreviewView(router: router, delegate: delegate)
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

    func showProgramStartConfigView(delegate: ProgramStartConfigDelegate) {
        router.showScreen(.sheet) { router in
            builder.programStartConfigView(router: router, delegate: delegate)
        }
    }

    func showExerciseTemplateListView(delegate: ExerciseTemplateListDelegate) {
        router.showScreen(.push) { router in
            builder.exerciseTemplateListView(router: router, delegate: delegate)
        }
    }

    func showExerciseTemplateDetailView(delegate: ExerciseTemplateDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.exerciseTemplateDetailView(router: router, delegate: delegate)
        }
    }

    func showWorkoutTemplateListView() {
        router.showScreen(.push) { router in
            builder.workoutTemplateListView(router: router)
        }
    }

    func showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.workoutTemplateDetailView(router: router, delegate: delegate)
        }
    }

    func showIngredientTemplateListView(delegate: IngredientTemplateListDelegate) {
        router.showScreen(.push) { router in
            builder.ingredientTemplateListView(router: router, delegate: delegate)
        }
    }

    func showRecipeTemplateListView(delegate: RecipeTemplateListDelegate) {
        router.showScreen(.push) { router in
            builder.recipeTemplateListView(router: router, delegate: delegate)
        }
    }

    func showProfileEditView() {
        router.showScreen(.push) { router in
            builder.profileEditView(router: router)
        }
    }

    func showSetGoalFlowView() {
        router.showScreen(.fullScreenCover) { router in
            builder.setGoalFlowView(router: router)
        }
    }

    func showWorkoutNotesView(delegate: WorkoutNotesDelegate) {
        router.showScreen(.sheet) { router in
            builder.workoutNotesView(router: router, delegate: delegate)
        }
    }

    func showProfileNutritionDetailView() {
        router.showScreen(.push) { router in
            builder.profileNutritionDetailView(router: router)
        }
    }

    func showMealDetailView(delegate: MealDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.mealDetailView(router: router, delegate: delegate)
        }
    }

    func showCustomProgramBuilderView() {
        router.showScreen(.push) { router in
            builder.customProgramBuilderView(router: router)
        }
    }
    
    func showEditProgramView(delegate: EditProgramDelegate) {
        router.showScreen(.push) { router in
            builder.editProgramView(router: router, delegate: delegate)
        }
    }

    func showLogWeightView() {
        router.showScreen(.push) { router in
            builder.logWeightView(router: router)
        }
    }

    func dismissScreen() {
        router.dismissScreen()
    }

    // MARK: Alerts

    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }

    func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: buttons)
    }

    func showSimpleAlert(title: String, subtitle: String?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: nil)
    }

    func showConfirmationDialog(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(.confirmationDialog, title: title, subtitle: subtitle, buttons: buttons)
    }

    // MARK: Modals

    func dismissModal() {
        router.dismissModal()
    }

    func showWarmupSetInfoModal(primaryButtonAction: @escaping () -> Void) {
        router.showModal(
            backgroundColor: .black,
            transition: .move(edge: .bottom),
            destination: {
                CustomModalView(
                    title: "Warmup Sets",
                    subtitle: "Warmup sets are lighter weight sets performed before your working sets to prepare your muscles and joints. They don't count toward your total volume or personal records.",
                    primaryButtonTitle: "Got it",
                    primaryButtonAction: {
                        primaryButtonAction()
                    },
                    secondaryButtonTitle: "",
                    secondaryButtonAction: {}
                )
            }
        )
    }
}

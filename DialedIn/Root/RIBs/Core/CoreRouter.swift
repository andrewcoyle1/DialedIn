//
//  CoreRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/11/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
struct CoreRouter: GlobalRouter {

    let router: AnyRouter
    private let builder: CoreBuilder

    init(router: AnyRouter, builder: CoreBuilder) {
        self.router = router
        self.builder = builder
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

    // MARK: Modals

    func showWarmupSetInfoModal(primaryButtonAction: @escaping () -> Void) {
        router.showModal(
            transition: .move(edge: .bottom),
            backgroundColor: .black,
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

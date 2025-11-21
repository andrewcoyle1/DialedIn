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

    func showCreateWorkoutView(delegate: CreateWorkoutViewDelegate) {
        router.showScreen(.fullScreenCover) { _ in
            builder.createWorkoutView(delegate: delegate)
        }
    }

    func showWorkoutStartView(delegate: WorkoutStartViewDelegate) {
        router.showScreen(.sheet) { router in
            builder.workoutStartView(router: router, delegate: delegate)
        }
    }

    func showWorkoutTrackerView(delegate: WorkoutTrackerViewDelegate) {
        router.showScreen(.fullScreenCover) { _ in
            builder.workoutTrackerView(delegate: delegate)
        }
    }

    func showCreateIngredientView() {
        router.showScreen(.sheet) { _ in
            builder.createIngredientView()
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

    func showStartRecipeView(delegate: RecipeStartViewDelegate) {
        router.showScreen(.push) { router in
            builder.recipeStartView(router: router, delegate: delegate)
        }
    }

    func showNutritionLibraryPickerView(delegate: NutritionLibraryPickerViewDelegate) {
        router.showScreen(.sheet) { _ in
            builder.nutritionLibraryPickerView(delegate: delegate)
        }
    }

    func showSettingsView() {
        router.showScreen(.push) { router in
            builder.settingsView(router: router)
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
        router.showScreen(.sheet) { _ in
            builder.programManagementView(delegate: ProgramManagementViewDelegate(path: .constant([])))
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
}

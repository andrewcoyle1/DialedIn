//
//  SearchQuickActionTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 22/09/2026.
//

import Testing
import Foundation
import SwiftUI
@testable import DialedIn

/// The Add tab's quick actions, and specifically the one that browses the exercise library.
///
/// The exercise list has no destination of its own: it hands a tapped row to the closure the caller
/// supplied. "Browse Exercises" opened it with an empty delegate, so the screen it opened was a
/// dead end — every row tapped into a nil closure and nothing happened.
@MainActor
struct SearchQuickActionTests {

    private final class Interactor: SpyGlobalInteractor, SearchInteractor {
        var shortcutSettings: ShortcutSettings = ShortcutSettings(authorId: "user-1")
        var userImageUrl: String?
        var currentUser: UserModel? = UserModel(userId: "user-1")
        var draftMeal: MealLogModel?
        var recentSearchQueries: [String] = []
        var followingIds: [String] = []
        var allExercises: [ExerciseModel] = []
        var allWorkoutTemplates: [WorkoutTemplateModel] = []
        var userWorkoutTemplates: [WorkoutTemplateModel] = []
        var userRecipeTemplates: [RecipeTemplateModel] = []
        var foods: [FoodModel] = []
        var followingUsers: [UserModel] = []

        func startWorkout(for template: WorkoutTemplateModel, in trainingProgramId: String?) async throws { }
        func searchUsers(query: String) async throws -> [UserModel] { [] }
        func addRecentSearch(query: String) { }
        func updateActiveSession(_ session: WorkoutSessionModel) throws { }
        func clearRecentSearches() { recentSearchQueries = [] }
        func getPreference(templateId: String) -> ExerciseUnitPreference {
            ExerciseUnitPreference(exerciseModelId: templateId)
        }
        func followUser(userId: String) async throws { }
        func unfollowUser(userId: String) async throws { }
    }

    private final class Router: SearchRouter {
        let router: AnyRouter = TestRouting.anyRouter
        private(set) var shown: [String] = []
        private(set) var exerciseListDelegates: [ExerciseListBuilderDelegate] = []
        private(set) var exerciseDetailIds: [String] = []

        func showProfileViewZoom(transitionId: String?, namespace: Namespace.ID) { shown.append("profile") }
        func showExerciseDetailView(templateId: String, name: String, delegate: ExerciseDetailDelegate, themeColor: Color?) {
            shown.append("exerciseDetail")
            exerciseDetailIds.append(templateId)
        }
        func showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate) { shown.append("workoutDetail") }
        func showRecipeDetailView(delegate: RecipeDetailDelegate) { shown.append("recipeDetail") }
        func showFoodDetailView(delegate: FoodDetailDelegate) { shown.append("foodDetail") }
        func showRecipesView() { shown.append("recipes") }
        func showAddMealView(delegate: AddMealDelegate) { shown.append("addMeal") }
        func showWorkoutsView(delegate: WorkoutsDelegate) { shown.append("workouts") }
        func showCreateExerciseView() { shown.append("createExercise") }
        func showExerciseListBuilderView(delegate: ExerciseListBuilderDelegate) {
            shown.append("exerciseList")
            exerciseListDelegates.append(delegate)
        }
        func showWorkoutTrackerView() { shown.append("workoutTracker") }
        func showLogWeightView() { shown.append("logWeight") }
        func showShortcutsView(delegate: ShortcutsDelegate) { shown.append("shortcuts") }
    }

    private func makeScreen() -> (SearchPresenter, Router) {
        let router = Router()
        return (SearchPresenter(interactor: Interactor(), router: router), router)
    }

    @Test("Test Browsing Exercises Opens A List Whose Rows Lead Somewhere")
    func testBrowsingExercisesOpensAListWhoseRowsLeadSomewhere() {
        let (presenter, router) = makeScreen()

        presenter.onQuickActionPressed(.browseExercises)

        #expect(router.shown == ["exerciseList"])
        #expect(router.exerciseListDelegates.first?.onExerciseSelectionChanged != nil)
    }

    /// And the row goes to the exercise's detail, the same place the search results' own rows go.
    @Test("Test A Browsed Exercise Opens Its Detail")
    func testABrowsedExerciseOpensItsDetail() {
        let (presenter, router) = makeScreen()

        presenter.onQuickActionPressed(.browseExercises)
        router.exerciseListDelegates.first?.onExerciseSelectionChanged?(searchExercise(id: "ex-1"))

        #expect(router.shown == ["exerciseList", "exerciseDetail"])
        #expect(router.exerciseDetailIds == ["ex-1"])
    }
}

@MainActor
private func searchExercise(id: String) -> ExerciseModel {
    ExerciseModel(
        id: id,
        authorId: "user-1",
        name: "Bench Press",
        trackableMetrics: [.weight, .reps],
        type: .compoundUpper,
        laterality: .bilateral,
        muscleGroups: [.chest: .primary],
        isBodyweight: false,
        rangeOfMotion: 4,
        stability: 5,
        bodyWeightContribution: 0,
        alternateNames: []
    )
}

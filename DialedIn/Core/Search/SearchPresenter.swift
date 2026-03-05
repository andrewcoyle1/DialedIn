//
//  SearchPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/01/2026.
//

import SwiftUI

@Observable
@MainActor
class SearchPresenter {
    
    private let interactor: SearchInteractor
    private let router: SearchRouter
    
    var searchString: String = ""
    
    var trimmedSearchString: String {
        self.searchString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .alphanumerics.inverted)
            .lowercased()
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }

    var filteredExercises: [ExerciseModel] {
        allExercises
            .filter {
                $0.name
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: .alphanumerics.inverted)
                    .lowercased().contains(trimmedSearchString) ||
                $0.description?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: .alphanumerics.inverted)
                    .lowercased()
                    .contains(trimmedSearchString) == true ||
                $0.muscleGroups
                    .contains { $0.key.rawValue
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .trimmingCharacters(in: .alphanumerics.inverted)
                            .lowercased()
                            .contains(trimmedSearchString)
                    } ||
                $0.alternateNames
                    .contains {
                        $0
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .trimmingCharacters(in: .alphanumerics.inverted)
                            .lowercased()
                            .contains(trimmedSearchString)
                    }
            }
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }

    var allExercises: [ExerciseModel] {
        interactor.allExercises
    }
    
    var filteredWorkoutTemplates: [WorkoutTemplateModel] {
        allWorkouts
            .filter {
                $0.name
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: .alphanumerics.inverted)
                    .lowercased()
                    .contains(trimmedSearchString.lowercased()) ||
                $0.description?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: .alphanumerics.inverted)
                    .lowercased()
                    .contains(trimmedSearchString.lowercased()) == true ||
                $0.exercises.contains(where: { $0.exercise.name
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .trimmingCharacters(in: .alphanumerics.inverted)
                        .lowercased()
                    .contains(trimmedSearchString.lowercased()) })
            }
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }
    
    var allWorkouts: [WorkoutTemplateModel] {
        interactor.allWorkoutTemplates
    }
    
    var filteredRecipeTemplates: [RecipeTemplateModel] {
        allRecipeTemplates
            .filter {
                $0.name
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: .alphanumerics.inverted)
                    .lowercased()
                    .contains(trimmedSearchString.lowercased()) ||
                $0.description?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: .alphanumerics.inverted)
                    .lowercased()
                    .contains(trimmedSearchString.lowercased()) == true ||
                $0.ingredients
                    .contains { value in
                        value.name
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .trimmingCharacters(in: .alphanumerics.inverted)
                            .lowercased()
                            .contains(trimmedSearchString.lowercased())
                    } == true
            }
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }
    
    var allRecipeTemplates: [RecipeTemplateModel] {
        interactor.userRecipeTemplates
    }

    var filteredIngredientTemplates: [IngredientTemplateModel] {
        allIngredientTemplates
            .filter {
                $0.name
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: .alphanumerics.inverted)
                    .lowercased()
                    .contains(trimmedSearchString.lowercased()) ||
                $0.description?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: .alphanumerics.inverted)
                    .lowercased()
                    .contains(trimmedSearchString.lowercased()) == true
            }
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }
    
    var allIngredientTemplates: [IngredientTemplateModel] {
        interactor.ingredientTemplates
    }
    
    var filteredUsers: [UserModel] {
        allUsers
            .filter {
                $0.firstNameCalculated?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: .alphanumerics.inverted)
                    .lowercased().contains(trimmedSearchString) == true
            }
//            .sortedByKeyPath(keyPath: \.firstNameCalculated, ascending: true)
    }

    var followingUsers: [UserModel] {
        interactor.followingUsers
    }

    var allUsers: [UserModel] {
        followingUsers + users
    }
    
    private(set) var users: [UserModel] = []
    private(set) var isLoading: Bool = false

    private var searchTask: Task<Void, Never>?

    private(set) var recentQueries: [String] = []

    var userImageUrl: String? {
        interactor.userImageUrl
    }

    var hasSearchQuery: Bool {
        !trimmedSearchString.isEmpty
    }

    var hasResults: Bool {
        !filteredExercises.isEmpty || !filteredWorkoutTemplates.isEmpty || !filteredRecipeTemplates.isEmpty || !filteredIngredientTemplates.isEmpty || !users.isEmpty
    }

    func isFollowing(userId: String) -> Bool {
        interactor.followingIds.contains(userId)
    }

    init(
        interactor: SearchInteractor,
        router: SearchRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func performUnifiedSearch() {
        searchTask?.cancel()

        guard hasSearchQuery else {
            onSearchCleared()
            return
        }

        let query = trimmedSearchString
        searchTask = Task { 
            isLoading = true
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }

            let fetchedUsers = (try? await interactor.searchUsers(query: query)) ?? []
            guard !Task.isCancelled else { return }

            users = fetchedUsers
            isLoading = false
            interactor.addRecentSearch(query: query)
        }
    }

    func onSearchCleared() {
        users = []
        reloadRecentQueries()
    }

    func loadRecentSearches() async {
        reloadRecentQueries()
    }

    private func reloadRecentQueries() {
        recentQueries = interactor.recentSearchQueries
    }

    func onExercisePressed(exercise: ExerciseModel) {
        router.showExerciseDetailView(
            templateId: exercise.id,
            name: exercise.name,
            delegate: ExerciseDetailDelegate(),
            themeColor: nil
        )
    }

    func onWorkoutPressed(workout: WorkoutTemplateModel) {
        router.showWorkoutTemplateDetailView(
            delegate: WorkoutTemplateDetailDelegate(workoutTemplate: workout)
        )
    }

    func onRecipePressed(recipe: RecipeTemplateModel) {
        router.showRecipeDetailView(
            delegate: RecipeDetailDelegate(recipeTemplate: recipe)
        )
    }

    func onRecentSearchTapped(query: String) {
        searchString = query
        performUnifiedSearch()
    }
    
    func onLogWeightPressed() {
        router.showLogWeightView()
    }

    func onClearRecentSearchesPressed() {
        interactor.clearRecentSearches()
        recentQueries = []
    }

    func onStartWorkoutPressed() {
        router.showWorkoutsView()
    }

    func onLogMealPressed() {
        guard let userId = currentUser?.userId else { return }
        if let meal = interactor.draftMeal {
            router.showAlert(
                title: "Unable to add new meal",
                subtitle: "You already have an draft meal.",
                buttons: {
                    AnyView(
                        VStack {
                            Button("Continue editing") {
                                self.router.showAddMealView(
                                    delegate: AddMealDelegate(mealLog: meal)
                                )
                            }
                            Button("Delete drafted meal", role: .destructive) {
                                self.router.showAddMealView(
                                    delegate: AddMealDelegate(
                                        mealLog: MealLogModel(
                                            authorId: userId,
                                            dayKey: Date().dayKey,
                                            date: Date(),
                                            items: [],
                                            totalCalories: 0,
                                            totalProteinGrams: 0,
                                            totalCarbGrams: 0,
                                            totalFatGrams: 0
                                        )
                                    )
                                )
                            }
                            Button("Cancel", role: .cancel) { }
                        }
                    )
                }
            )
        } else {
            self.router.showAddMealView(
                delegate: AddMealDelegate(
                    mealLog: MealLogModel(
                        authorId: userId,
                        dayKey: Date().dayKey,
                        date: Date(),
                        items: [],
                        totalCalories: 0,
                        totalProteinGrams: 0,
                        totalCarbGrams: 0,
                        totalFatGrams: 0
                    )
                )
            )
        }
    }

    func onIngredientPressed(ingredient: IngredientTemplateModel) {
        router.showIngredientDetailView(delegate: IngredientDetailDelegate(ingredientTemplate: ingredient))
    }
    
    func onAddExercisePressed() {
        router.showCreateExerciseView()
    }

    func onFollowPressed(user: UserModel) {
        Task {
            do {
                try await interactor.followUser(userId: user.userId)
            } catch {
                router.showSimpleAlert(title: "Unable to follow user", subtitle: "Please try again.")
            }
        }
    }

    func onUnfollowPressed(user: UserModel) {
        Task {
            do {
                try await interactor.unfollowUser(userId: user.userId)
            } catch {
                router.showSimpleAlert(title: "Unable to unfollow user", subtitle: "Please try again.")
            }
        }
    }

    func onProfilePressed() {
        router.showProfileView()
    }

    private func showWorkoutStartModal(for template: WorkoutTemplateModel) {
        router.showWorkoutStartModal(
            delegate: WorkoutStartDelegate(
                template: template,
                trainingProgramId: nil,
                onStartWorkoutPressed: { [weak self] in
                    guard let self else { return }
                    Task {
                        do {
                            try await self.interactor.startWorkout(for: template, in: nil)
                            self.router.dismissModal()
                            self.router.dismissEnvironment()
                            self.router.showWorkoutTrackerView()
                        } catch {
                            self.router.showSimpleAlert(title: "Unable to start workout", subtitle: "Please try again.")
                        }
                    }
                },
                onCancelPressed: { [weak self] in
                    self?.router.dismissModal()
                }
            )
        )
    }
}

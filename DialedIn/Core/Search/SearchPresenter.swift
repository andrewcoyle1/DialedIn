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

    var filteredFoods: [FoodModel] {
        allFoods
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
    
    var allFoods: [FoodModel] {
        interactor.foods
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

    /// Checks `filteredUsers`, not `users`: the view renders the filtered list, so a remote search
    /// that returned people whose names the local filter then rejected showed a list of five empty
    /// sections instead of "no results".
    var hasResults: Bool {
        !filteredExercises.isEmpty
            || !filteredWorkoutTemplates.isEmpty
            || !filteredRecipeTemplates.isEmpty
            || !filteredFoods.isEmpty
            || !filteredUsers.isEmpty
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
            delegate: WorkoutTemplateDetailDelegate(
                workoutTemplate: workout,
                trainingProgramId: nil,
                onStartWorkoutPressed: { [weak self] in
                    Task { @MainActor in
                        self?.router.showWorkoutTrackerView()
                    }
                }
            )
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

    // MARK: - Quick actions

    /// The Add tab's grid, as chosen on the Shortcuts screen.
    var quickActions: [QuickAction] {
        interactor.shortcutSettings.quickActions
    }

    /// One switch instead of a per-action closure at the call site, so adding a `QuickAction` case is
    /// a compile error here until it is routed somewhere.
    func onQuickActionPressed(_ action: QuickAction) {
        // The eventName overload rather than a nested `Event` enum: this presenter tracks nothing
        // else, and one case does not justify the enum.
        interactor.trackEvent(
            eventName: "SearchView_QuickAction_Press",
            parameters: ["action": action.rawValue],
            type: .analytic
        )
        switch action {
        case .startWorkout:    onStartWorkoutPressed()
        case .addExercise:     onAddExercisePressed()
        case .logMeal:         onLogMealPressed()
        case .logWeight:       onLogWeightPressed()
        case .browseWorkouts:  router.showWorkoutsView(delegate: WorkoutsDelegate())
        case .browseExercises: router.showExerciseListBuilderView(delegate: ExerciseListBuilderDelegate())
        case .browseRecipes:   router.showRecipesView()
        }
    }

    func onStartWorkoutPressed() {
        router.showWorkoutsView(delegate: WorkoutsDelegate())
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
                                            items: []
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
                        items: []
                    )
                )
            )
        }
    }

    func onIngredientPressed(ingredient: FoodModel) {
        router.showFoodDetailView(delegate: FoodDetailDelegate(food: ingredient))
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

    /// The empty Add tab's way back to the screen that fills it.
    func onChooseShortcutsPressed() {
        router.showShortcutsView(delegate: ShortcutsDelegate())
    }

    func onProfilePressed(transitionId: String, namespace: Namespace.ID) {
        router.showProfileViewZoom(transitionId: transitionId, namespace: namespace)
    }
}

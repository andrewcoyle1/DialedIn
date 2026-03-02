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

    var filteredExercises: [ExerciseModel] = []
    var allExercises: [ExerciseModel] {
        interactor.allExercises
    }
    private(set) var users: [UserModel] = []
    private(set) var workouts: [WorkoutTemplateModel] = []
    private(set) var recipes: [RecipeTemplateModel] = []
    private(set) var isLoading: Bool = false

    private var searchTask: Task<Void, Never>?

    private(set) var recentQueries: [String] = []

    var userImageUrl: String? {
        interactor.userImageUrl
    }

    var trimmedSearchString: String {
        searchString.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasSearchQuery: Bool {
        !trimmedSearchString.isEmpty
    }

    var hasResults: Bool {
        !filteredExercises.isEmpty || !workouts.isEmpty || !recipes.isEmpty || !users.isEmpty
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

            let exercises = allExercises.filter { $0.name.localizedCaseInsensitiveContains(query) }
            let fetchedUsers = (try? await interactor.searchUsers(query: query)) ?? []
            guard !Task.isCancelled else { return }

            filteredExercises = exercises
            users = fetchedUsers
            isLoading = false
            interactor.addRecentSearch(query: query)
        }
    }

    func onSearchCleared() {
        filteredExercises = []
        users = []
        workouts = []
        recipes = []
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

    func onClearRecentSearchesPressed() {
        interactor.clearRecentSearches()
        recentQueries = []
    }

    func onStartWorkoutPressed() {
        router.showWorkoutPickerView(delegate: WorkoutPickerDelegate(
            onSelect: { [weak self] template in
                self?.showWorkoutStartModal(for: template)
            },
            onCancel: {}
        ))
    }

    func onLogMealPressed() {
        router.showRecipesView()
    }

    func onAddExercisePressed() {
        router.showExerciseListBuilderView(delegate: ExerciseListBuilderDelegate())
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

    func onProfilePressed(_ transitionId: String, in namespace: Namespace.ID) {
        router.showProfileViewZoom(
            transitionId: transitionId,
            namespace: namespace
        )
    }

    private func showWorkoutStartModal(for template: WorkoutTemplateModel) {
        guard let userId = interactor.currentUser?.userId else { return }
        router.showWorkoutStartModal(
            delegate: WorkoutStartDelegate(
                template: template,
                programId: nil,
                dayPlanId: nil,
                onStartWorkoutPressed: { [weak self] in
                    guard let self else { return }
                    // Load unit preferences and create session only when user confirms start
                    var unitPreferences: [String: ExerciseUnitPreference] = [:]
                    for exerciseModel in template.exercises {
                        let preference = self.interactor.getPreference(templateId: exerciseModel.exercise.id)
                        unitPreferences[exerciseModel.exercise.id] = preference
                    }
                    let session = WorkoutSessionModel(
                        authorId: userId,
                        template: template,
                        notes: nil,
                        scheduledWorkoutId: nil,
                        trainingPlanId: nil,
                        programId: nil,
                        dayPlanId: nil,
                        unitPreferences: unitPreferences
                    )
                    do {
                        // Set as active session locally (Firebase save happens on workout completion)
                        try self.interactor.updateActiveSession(session)
                        self.router.dismissModal()
                        self.router.dismissEnvironment()
                        self.router.showWorkoutTrackerView(delegate: WorkoutTrackerDelegate(workoutSessionId: session.id))
                    } catch {
                        self.router.showSimpleAlert(title: "Unable to start workout", subtitle: "Please try again.")
                    }
                },
                onCancelPressed: { [weak self] in
                    self?.router.dismissModal()
                }
            )
        )
    }
}

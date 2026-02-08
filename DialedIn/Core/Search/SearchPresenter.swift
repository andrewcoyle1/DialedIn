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

    private(set) var exercises: [ExerciseModel] = []
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
        !exercises.isEmpty || !workouts.isEmpty || !recipes.isEmpty
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
        searchTask = Task { @MainActor in
            isLoading = true
            do {
                try await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }

                let exercisesResult = try await interactor.getExerciseTemplatesByName(name: query)
                guard !Task.isCancelled else { return }
                let workoutsResult = try await interactor.getWorkoutTemplatesByName(name: query)
                guard !Task.isCancelled else { return }
                let recipesResult = try await interactor.getRecipeTemplatesByName(name: query)

                exercises = exercisesResult
                workouts = workoutsResult
                recipes = recipesResult
                isLoading = false
                interactor.addRecentSearch(query: query)
            } catch {
                isLoading = false
                exercises = []
                workouts = []
                recipes = []
                router.showSimpleAlert(
                    title: "Search Failed",
                    subtitle: "We couldn't complete your search. Please try again."
                )
            }
        }
    }

    func onSearchCleared() {
        exercises = []
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
            delegate: ExerciseDetailDelegate()
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

    func onProfilePressed(_ transitionId: String, in namespace: Namespace.ID) {
        router.showProfileViewZoom(
            transitionId: transitionId,
            namespace: namespace
        )
    }

    private func showWorkoutStartModal(for template: WorkoutTemplateModel) {
        guard let userId = interactor.currentUser?.userId else { return }
        let session = WorkoutSessionModel(
            authorId: userId,
            template: template,
            notes: nil,
            scheduledWorkoutId: nil,
            trainingPlanId: nil,
            programId: nil,
            dayPlanId: nil
        )
        router.showWorkoutStartModal(
            delegate: WorkoutStartDelegate(
                template: template,
                scheduledWorkout: nil,
                programId: nil,
                dayPlanId: nil,
                onStartWorkoutPressed: { [weak self] in
                    guard let self else { return }
                    do {
                        try self.interactor.addLocalWorkoutSession(session: session)
                        self.interactor.startActiveSession(session)
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

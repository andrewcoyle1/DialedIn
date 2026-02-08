//
//  SearchInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/01/2026.
//

protocol SearchInteractor {
    var userImageUrl: String? { get }
    var currentUser: UserModel? { get }
    var recentSearchQueries: [String] { get }
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseModel]
    func getWorkoutTemplatesByName(name: String) async throws -> [WorkoutTemplateModel]
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel]
    func addRecentSearch(query: String)
    func clearRecentSearches()
    func addLocalWorkoutSession(session: WorkoutSessionModel) throws
    func startActiveSession(_ session: WorkoutSessionModel)
}

extension CoreInteractor: SearchInteractor {
    var recentSearchQueries: [String] {
        RecentSearchManager.recentSearchQueries
    }

    func addRecentSearch(query: String) {
        RecentSearchManager.addRecentSearch(query: query)
    }

    func clearRecentSearches() {
        RecentSearchManager.clearRecentSearches()
    }
}

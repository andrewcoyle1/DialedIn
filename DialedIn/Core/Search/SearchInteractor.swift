//
//  SearchInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/01/2026.
//

@MainActor
protocol SearchInteractor: GlobalInteractor {
    var userImageUrl: String? { get }
    var currentUser: UserModel? { get }
    var followingIds: [String] { get }
    var recentSearchQueries: [String] { get }
    var allExercises: [ExerciseModel] { get }
    var allWorkoutTemplates: [WorkoutTemplateModel] { get }
    var userWorkoutTemplates: [WorkoutTemplateModel] { get }
    var userRecipeTemplates: [RecipeTemplateModel] { get }
    var ingredientTemplates: [IngredientTemplateModel] { get }
    var followingUsers: [UserModel] { get }
    func startWorkout(for template: WorkoutTemplateModel, in trainingProgramId: String?) async throws
    func searchUsers(query: String) async throws -> [UserModel]
    func addRecentSearch(query: String)
    func updateActiveSession(_ session: WorkoutSessionModel) throws
    func clearRecentSearches()
    func getPreference(templateId: String) -> ExerciseUnitPreference
    func followUser(userId: String) async throws
    func unfollowUser(userId: String) async throws
}

extension CoreInteractor: SearchInteractor {
    var recentSearchQueries: [String] {
        RecentSearchManager.recentSearchQueries
    }

    var followingIds: [String] {
        currentUser?.followingIds ?? []
    }

    func searchUsers(query: String) async throws -> [UserModel] {
        let results = try await userManager.searchUsers(query: query)
        return results.filter { $0.userId != currentUser?.userId }
    }

    func addRecentSearch(query: String) {
        RecentSearchManager.addRecentSearch(query: query)
    }

    func clearRecentSearches() {
        RecentSearchManager.clearRecentSearches()
    }
}

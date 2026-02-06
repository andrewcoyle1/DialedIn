//
//  WorkoutTemplateDetailInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol WorkoutTemplateDetailInteractor {
    var currentUser: UserModel? { get }
    var activeSession: WorkoutSessionModel? { get }
    func addLocalWorkoutSession(session: WorkoutSessionModel) throws
    func startActiveSession(_ session: WorkoutSessionModel)
    func favouriteWorkoutTemplate(id: String, isFavourited: Bool) async throws
    func removeFavouritedWorkoutTemplate(workoutId: String) async throws
    func bookmarkWorkoutTemplate(id: String, isBookmarked: Bool) async throws
    func addBookmarkedWorkoutTemplate(workoutId: String) async throws
    func removeBookmarkedWorkoutTemplate(workoutId: String) async throws
    func addFavouritedWorkoutTemplate(workoutId: String) async throws
    func removeCreatedWorkoutTemplate(workoutId: String) async throws
    func deleteWorkoutTemplate(id: String) async throws
}

extension CoreInteractor: WorkoutTemplateDetailInteractor { }

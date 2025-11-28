//
//  ExerciseTemplateDetailInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

protocol ExerciseTemplateDetailInteractor {
    var currentUser: UserModel? { get }
    func getPreference(templateId: String) -> ExerciseUnitPreference
    func getExerciseHistoryForAuthor(authorId: String, limitTo: Int) async throws -> [ExerciseHistoryEntryModel]
    func getLocalExerciseHistoryForTemplate(templateId: String, limitTo: Int) throws -> [ExerciseHistoryEntryModel]
    func favouriteExerciseTemplate(id: String, isFavourited: Bool) async throws
    func removeFavouritedExerciseTemplate(exerciseId: String) async throws
    func bookmarkExerciseTemplate(id: String, isBookmarked: Bool) async throws
    func addBookmarkedExerciseTemplate(exerciseId: String) async throws
    func removeBookmarkedExerciseTemplate(exerciseId: String) async throws
    func addFavouritedExerciseTemplate(exerciseId: String) async throws
}

extension CoreInteractor: ExerciseTemplateDetailInteractor { }

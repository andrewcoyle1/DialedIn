//
//  LocalExerciseHistoryPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

protocol LocalExerciseHistoryPersistence {
    func addLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws
    func updateLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws
    func getLocalExerciseHistory(id: String) throws -> ExerciseHistoryEntryModel
    func getLocalExerciseHistoryForTemplate(templateId: String, limitTo: Int) throws -> [ExerciseHistoryEntryModel]
    func getLocalExerciseHistoryForAuthor(authorId: String, limitTo: Int) throws -> [ExerciseHistoryEntryModel]
    func getAllLocalExerciseHistory() throws -> [ExerciseHistoryEntryModel]
    func deleteLocalExerciseHistory(id: String) throws
    func deleteAllLocalExerciseHistoryForAuthor(authorId: String) throws
}

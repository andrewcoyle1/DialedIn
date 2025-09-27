//
//  RemoteExerciseHistoryService.swift
//  DialedIn
//
//  Created by AI Assistant on 27/09/2025.
//

protocol RemoteExerciseHistoryService {
    func createExerciseHistory(entry: ExerciseHistoryEntryModel) async throws
    func updateExerciseHistory(entry: ExerciseHistoryEntryModel) async throws
    func getExerciseHistory(id: String) async throws -> ExerciseHistoryEntryModel
    func getExerciseHistoryForTemplate(templateId: String, limitTo: Int) async throws -> [ExerciseHistoryEntryModel]
    func getExerciseHistoryForAuthor(authorId: String, limitTo: Int) async throws -> [ExerciseHistoryEntryModel]
    func deleteExerciseHistory(id: String) async throws
    func deleteAllExerciseHistoryForAuthor(authorId: String) async throws
}

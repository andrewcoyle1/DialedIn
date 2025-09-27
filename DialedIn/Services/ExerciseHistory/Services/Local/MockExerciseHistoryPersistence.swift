//
//  MockExerciseHistoryPersistence.swift
//  DialedIn
//
//  Created by AI Assistant on 27/09/2025.
//

import Foundation

@MainActor
struct MockExerciseHistoryPersistence: LocalExerciseHistoryPersistence {
    
    var entries: [ExerciseHistoryEntryModel]
    var showError: Bool
    
    init(entries: [ExerciseHistoryEntryModel] = ExerciseHistoryEntryModel.mocks, showError: Bool = false) {
        self.entries = entries
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func addLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws {
        try tryShowError()
    }
    
    func updateLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws {
        try tryShowError()
    }
    
    func getLocalExerciseHistory(id: String) throws -> ExerciseHistoryEntryModel {
        try tryShowError()
        if let entry = entries.first(where: { $0.id == id }) {
            return entry
        } else {
            throw NSError(domain: "MockExerciseHistoryPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "ExerciseHistory with id \(id) not found"])
        }
    }
    
    func getLocalExerciseHistoryForTemplate(templateId: String, limitTo: Int) throws -> [ExerciseHistoryEntryModel] {
        try tryShowError()
        let list = entries.filter { $0.templateId == templateId }
        return limitTo > 0 ? Array(list.prefix(limitTo)) : list
    }
    
    func getLocalExerciseHistoryForAuthor(authorId: String, limitTo: Int) throws -> [ExerciseHistoryEntryModel] {
        try tryShowError()
        let list = entries.filter { $0.authorId == authorId }
        return limitTo > 0 ? Array(list.prefix(limitTo)) : list
    }
    
    func getAllLocalExerciseHistory() throws -> [ExerciseHistoryEntryModel] {
        try tryShowError()
        return entries
    }
    
    func deleteLocalExerciseHistory(id: String) throws {
        try tryShowError()
    }
    
    func deleteAllLocalExerciseHistoryForAuthor(authorId: String) throws {
        try tryShowError()
    }
}

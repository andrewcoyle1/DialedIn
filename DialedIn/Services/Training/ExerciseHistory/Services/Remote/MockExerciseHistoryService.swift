//
//  MockExerciseHistoryService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import Foundation

struct MockExerciseHistoryService: RemoteExerciseHistoryService {
    let entries: [ExerciseHistoryEntryModel]
    let delay: Double
    let showError: Bool
    
    init(entries: [ExerciseHistoryEntryModel] = ExerciseHistoryEntryModel.mocks, delay: Double = 0.0, showError: Bool = false) {
        self.entries = entries
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createExerciseHistory(entry: ExerciseHistoryEntryModel) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func updateExerciseHistory(entry: ExerciseHistoryEntryModel) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func getExerciseHistory(id: String) async throws -> ExerciseHistoryEntryModel {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        guard let item = entries.first(where: { $0.id == id }) else {
            throw URLError(.unknown)
        }
        return item
    }
    
    func getExerciseHistoryForTemplate(templateId: String, limitTo: Int) async throws -> [ExerciseHistoryEntryModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        let list = entries.filter { $0.templateId == templateId }
        return limitTo > 0 ? Array(list.prefix(limitTo)) : list
    }
    
    func getExerciseHistoryForAuthor(authorId: String, limitTo: Int) async throws -> [ExerciseHistoryEntryModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        let list = entries.filter { $0.authorId == authorId }
        return limitTo > 0 ? Array(list.prefix(limitTo)) : list
    }
    
    func deleteExerciseHistory(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func deleteAllExerciseHistoryForAuthor(authorId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
}

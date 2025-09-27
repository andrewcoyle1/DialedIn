//
//  ExerciseHistoryManager.swift
//  DialedIn
//
//  Created by AI Assistant on 27/09/2025.
//

import SwiftUI

@MainActor
@Observable
class ExerciseHistoryManager {
    
    private let local: LocalExerciseHistoryPersistence
    private let remote: RemoteExerciseHistoryService
    
    init(services: ExerciseHistoryServices) {
        self.remote = services.remote
        self.local = services.local
    }
    
    // Local
    func addLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws {
        try local.addLocalExerciseHistory(entry: entry)
    }
    
    func updateLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws {
        try local.updateLocalExerciseHistory(entry: entry)
    }
    
    func getLocalExerciseHistory(id: String) throws -> ExerciseHistoryEntryModel {
        try local.getLocalExerciseHistory(id: id)
    }
    
    func getLocalExerciseHistoryForTemplate(templateId: String, limitTo: Int = 50) throws -> [ExerciseHistoryEntryModel] {
        try local.getLocalExerciseHistoryForTemplate(templateId: templateId, limitTo: limitTo)
    }
    
    func getLocalExerciseHistoryForAuthor(authorId: String, limitTo: Int = 50) throws -> [ExerciseHistoryEntryModel] {
        try local.getLocalExerciseHistoryForAuthor(authorId: authorId, limitTo: limitTo)
    }
    
    func getAllLocalExerciseHistory() throws -> [ExerciseHistoryEntryModel] {
        try local.getAllLocalExerciseHistory()
    }
    
    func deleteLocalExerciseHistory(id: String) throws {
        try local.deleteLocalExerciseHistory(id: id)
    }
    
    func deleteAllLocalExerciseHistoryForAuthor(authorId: String) throws {
        try local.deleteAllLocalExerciseHistoryForAuthor(authorId: authorId)
    }
    
    // Remote
    func createExerciseHistory(entry: ExerciseHistoryEntryModel) async throws {
        try await remote.createExerciseHistory(entry: entry)
    }
    
    func updateExerciseHistory(entry: ExerciseHistoryEntryModel) async throws {
        try await remote.updateExerciseHistory(entry: entry)
    }
    
    func getExerciseHistory(id: String) async throws -> ExerciseHistoryEntryModel {
        try await remote.getExerciseHistory(id: id)
    }
    
    func getExerciseHistoryForTemplate(templateId: String, limitTo: Int = 50) async throws -> [ExerciseHistoryEntryModel] {
        try await remote.getExerciseHistoryForTemplate(templateId: templateId, limitTo: limitTo)
    }
    
    func getExerciseHistoryForAuthor(authorId: String, limitTo: Int = 50) async throws -> [ExerciseHistoryEntryModel] {
        try await remote.getExerciseHistoryForAuthor(authorId: authorId, limitTo: limitTo)
    }
    
    func deleteExerciseHistory(id: String) async throws {
        try await remote.deleteExerciseHistory(id: id)
    }
    
    func deleteAllExerciseHistoryForAuthor(authorId: String) async throws {
        try await remote.deleteAllExerciseHistoryForAuthor(authorId: authorId)
    }
}

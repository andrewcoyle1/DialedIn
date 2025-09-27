//
//  SwiftExerciseHistoryPersistence.swift
//  DialedIn
//
//  Created by AI Assistant on 27/09/2025.
//

import SwiftData
import SwiftUI

@MainActor
struct SwiftExerciseHistoryPersistence: LocalExerciseHistoryPersistence {
    private let container: ModelContainer
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: ExerciseHistoryEntryEntity.self, WorkoutSetEntity.self, WorkoutExerciseEntity.self, WorkoutSessionEntity.self)
    }
    
    func addLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws {
        let entity = ExerciseHistoryEntryEntity(from: entry)
        mainContext.insert(entity)
        try mainContext.save()
    }
    
    func updateLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws {
        let id = entry.id
        let predicate = #Predicate<ExerciseHistoryEntryEntity> { $0.exerciseHistoryEntryId == id }
        let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftExerciseHistoryPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "ExerciseHistory with id \(id) not found"])
        }
        entity.authorId = entry.authorId
        entity.templateId = entry.templateId
        entity.templateName = entry.templateName
        entity.workoutSessionId = entry.workoutSessionId
        entity.workoutExerciseId = entry.workoutExerciseId
        entity.performedAt = entry.performedAt
        entity.notes = entry.notes
        entity.sets = entry.sets.map { WorkoutSetEntity(from: $0) }
        entity.dateCreated = entry.dateCreated
        entity.dateModified = entry.dateModified
        try mainContext.save()
    }
    
    func getLocalExerciseHistory(id: String) throws -> ExerciseHistoryEntryModel {
        let predicate = #Predicate<ExerciseHistoryEntryEntity> { $0.exerciseHistoryEntryId == id }
        let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftExerciseHistoryPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "ExerciseHistory with id \(id) not found"])
        }
        return entity.toModel()
    }
    
    func getLocalExerciseHistoryForTemplate(templateId: String, limitTo: Int) throws -> [ExerciseHistoryEntryModel] {
        let predicate = #Predicate<ExerciseHistoryEntryEntity> { $0.templateId == templateId }
        let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(predicate: predicate, sortBy: [SortDescriptor(\.performedAt, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        let limited = limitTo > 0 ? Array(entities.prefix(limitTo)) : entities
        return limited.map { $0.toModel() }
    }
    
    func getLocalExerciseHistoryForAuthor(authorId: String, limitTo: Int) throws -> [ExerciseHistoryEntryModel] {
        let predicate = #Predicate<ExerciseHistoryEntryEntity> { $0.authorId == authorId }
        let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(predicate: predicate, sortBy: [SortDescriptor(\.performedAt, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        let limited = limitTo > 0 ? Array(entities.prefix(limitTo)) : entities
        return limited.map { $0.toModel() }
    }
    
    func getAllLocalExerciseHistory() throws -> [ExerciseHistoryEntryModel] {
        let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(sortBy: [SortDescriptor(\.performedAt, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    func deleteLocalExerciseHistory(id: String) throws {
        let predicate = #Predicate<ExerciseHistoryEntryEntity> { $0.exerciseHistoryEntryId == id }
        let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftExerciseHistoryPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "ExerciseHistory with id \(id) not found"])
        }
        mainContext.delete(entity)
        try mainContext.save()
    }
    
    func deleteAllLocalExerciseHistoryForAuthor(authorId: String) throws {
        let predicate = #Predicate<ExerciseHistoryEntryEntity> { $0.authorId == authorId }
        let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        for entity in entities { mainContext.delete(entity) }
        try mainContext.save()
    }
}

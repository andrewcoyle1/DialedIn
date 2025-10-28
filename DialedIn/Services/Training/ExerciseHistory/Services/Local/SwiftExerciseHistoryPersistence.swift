//
//  SwiftExerciseHistoryPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftData
import SwiftUI

class SwiftExerciseHistoryPersistence: LocalExerciseHistoryPersistence {
    private var container: ModelContainer
    private let storeURL: URL
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // Use a fixed store location and ensure directory exists
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = appSupport.appendingPathComponent("DialedIn.ExerciseHistoryStore", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        self.storeURL = directory.appendingPathComponent("ExerciseHistory.store")

        let configuration = ModelConfiguration(url: storeURL)
            // swiftlint:disable:next force_try
            self.container = try! ModelContainer(for: ExerciseHistoryEntryEntity.self, ExerciseHistorySetEntity.self, configurations: configuration)
        
    }

    private func isSchemaMismatchError(_ error: any Error) -> Bool {
        let nsError = error as NSError
        if nsError.domain == "NSSQLiteErrorDomain" { return true }
        if nsError.localizedDescription.contains("no such table") { return true }
        if nsError.localizedDescription.contains("Fetching maximum primary key failed") { return true }
        if nsError.localizedDescription.contains("The file couldn\'t be opened") { return true }
        return false
    }

    private func rebuildContainer() {
        try? FileManager.default.removeItem(at: storeURL)

        let configuration = ModelConfiguration(url: storeURL)
            // swiftlint:disable:next force_try
            self.container = try! ModelContainer(for: ExerciseHistoryEntryEntity.self, ExerciseHistorySetEntity.self, configurations: configuration)
        
    }
    
    func addLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws {
        do {
            let entity = ExerciseHistoryEntryEntity(from: entry)
            mainContext.insert(entity)
            try mainContext.save()
        } catch {
            if isSchemaMismatchError(error) {
                rebuildContainer()
                let entity = ExerciseHistoryEntryEntity(from: entry)
                mainContext.insert(entity)
                try mainContext.save()
            } else {
                throw error
            }
        }
    }
    
    func updateLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws {
        do {
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
            entity.sets = entry.sets.map { ExerciseHistorySetEntity(from: $0) }
            entity.dateCreated = entry.dateCreated
            entity.dateModified = entry.dateModified
            try mainContext.save()
        } catch {
            if isSchemaMismatchError(error) {
                rebuildContainer()
                try updateLocalExerciseHistory(entry: entry)
            } else {
                throw error
            }
        }
    }
    
    func getLocalExerciseHistory(id: String) throws -> ExerciseHistoryEntryModel {
        do {
            let predicate = #Predicate<ExerciseHistoryEntryEntity> { $0.exerciseHistoryEntryId == id }
            let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(predicate: predicate)
            let entities = try mainContext.fetch(descriptor)
            guard let entity = entities.first else {
                throw NSError(domain: "SwiftExerciseHistoryPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "ExerciseHistory with id \(id) not found"])
            }
            return entity.toModel()
        } catch {
            if isSchemaMismatchError(error) {
                return ExerciseHistoryEntryModel.mocks.first!
            } else {
                throw error
            }
        }
    }
    
    func getLocalExerciseHistoryForTemplate(templateId: String, limitTo: Int) throws -> [ExerciseHistoryEntryModel] {
        do {
            let predicate = #Predicate<ExerciseHistoryEntryEntity> { $0.templateId == templateId }
            let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(predicate: predicate, sortBy: [SortDescriptor(\.performedAt, order: .reverse)])
            let entities = try mainContext.fetch(descriptor)
            let limited = limitTo > 0 ? Array(entities.prefix(limitTo)) : entities
            return limited.map { $0.toModel() }
        } catch {
            if isSchemaMismatchError(error) {
                return []
            } else {
                throw error
            }
        }
    }
    
    func getLocalExerciseHistoryForAuthor(authorId: String, limitTo: Int) throws -> [ExerciseHistoryEntryModel] {
        do {
            let predicate = #Predicate<ExerciseHistoryEntryEntity> { $0.authorId == authorId }
            let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(predicate: predicate, sortBy: [SortDescriptor(\.performedAt, order: .reverse)])
            let entities = try mainContext.fetch(descriptor)
            let limited = limitTo > 0 ? Array(entities.prefix(limitTo)) : entities
            return limited.map { $0.toModel() }
        } catch {
            if isSchemaMismatchError(error) {
                return []
            } else {
                throw error
            }
        }
    }
    
    func getAllLocalExerciseHistory() throws -> [ExerciseHistoryEntryModel] {
        do {
            let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(sortBy: [SortDescriptor(\.performedAt, order: .reverse)])
            let entities = try mainContext.fetch(descriptor)
            return entities.map { $0.toModel() }
        } catch {
            if isSchemaMismatchError(error) {
                return []
            } else {
                throw error
            }
        }
    }
    
    func deleteLocalExerciseHistory(id: String) throws {
        do {
            let predicate = #Predicate<ExerciseHistoryEntryEntity> { $0.exerciseHistoryEntryId == id }
            let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(predicate: predicate)
            let entities = try mainContext.fetch(descriptor)
            guard let entity = entities.first else {
                throw NSError(domain: "SwiftExerciseHistoryPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "ExerciseHistory with id \(id) not found"])
            }
            mainContext.delete(entity)
            try mainContext.save()
        } catch {
            if isSchemaMismatchError(error) {
                rebuildContainer()
            } else {
                throw error
            }
        }
    }
    
    func deleteAllLocalExerciseHistoryForAuthor(authorId: String) throws {
        do {
            let predicate = #Predicate<ExerciseHistoryEntryEntity> { $0.authorId == authorId }
            let descriptor = FetchDescriptor<ExerciseHistoryEntryEntity>(predicate: predicate)
            let entities = try mainContext.fetch(descriptor)
            for entity in entities { mainContext.delete(entity) }
            try mainContext.save()
        } catch {
            if isSchemaMismatchError(error) {
                rebuildContainer()
            } else {
                throw error
            }
        }
    }
}

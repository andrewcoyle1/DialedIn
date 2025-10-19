//
//  SwiftWorkoutSessionPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftData
import SwiftUI

@MainActor
class SwiftWorkoutSessionPersistence: LocalWorkoutSessionPersistence {
    private var container: ModelContainer
    private let storeURL: URL
    private let activeSessionDefaultsKey = "activeWorkoutSessionId"
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // Create Application Support path and a fixed store URL for easier resets/migrations
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = appSupport.appendingPathComponent("DialedIn.LocalStore", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        self.storeURL = directory.appendingPathComponent("WorkoutSessions.store")

        let configuration = ModelConfiguration(url: storeURL)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(
                for: WorkoutSessionEntity.self, WorkoutExerciseEntity.self, WorkoutSetEntity.self,
                configurations: configuration)
           
    }

    private func rebuildContainer() {
        // Remove the existing store file to resolve missing table/schema mismatches
        try? FileManager.default.removeItem(at: storeURL)

        let configuration = ModelConfiguration(url: storeURL)
            // swiftlint:disable:next force_try
            self.container = try! ModelContainer(
                for: WorkoutSessionEntity.self, WorkoutExerciseEntity.self, WorkoutSetEntity.self,
                configurations: configuration
            )
        
    }

    private func isSchemaMismatchError(_ error: any Error) -> Bool {
        let nsError = error as NSError
        if nsError.domain == "NSSQLiteErrorDomain" { return true }
        if nsError.localizedDescription.contains("no such table") { return true }
        if nsError.localizedDescription.contains("Fetching maximum primary key failed") { return true }
        return false
    }
    
    func addLocalWorkoutSession(session: WorkoutSessionModel) throws {
        do {
            let entity = WorkoutSessionEntity(from: session)
            mainContext.insert(entity)
            try mainContext.save()
        } catch {
            if isSchemaMismatchError(error) {
                rebuildContainer()
                let entity = WorkoutSessionEntity(from: session)
                mainContext.insert(entity)
                try mainContext.save()
            } else {
                throw error
            }
        }
    }
    
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws {
        // Avoid capturing non-Sendable 'session' in the predicate closure
        let id = session.id
        do {
            let predicate = #Predicate<WorkoutSessionEntity> { $0.workoutSessionId == id }
            let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate)
            let entities = try mainContext.fetch(descriptor)
            guard let entity = entities.first else {
                throw NSError(domain: "SwiftWorkoutSessionPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutSession with id \(id) not found"])
            }
            entity.authorId = session.authorId
            entity.dateCreated = session.dateCreated
            entity.endedAt = session.endedAt
            entity.notes = session.notes
            // Persist exercises in a deterministic order based on their index
            entity.exercises = session.exercises
                .sorted { $0.index < $1.index }
                .map { WorkoutExerciseEntity(from: $0) }
            try mainContext.save()
        } catch {
            if isSchemaMismatchError(error) {
                rebuildContainer()
                try updateLocalWorkoutSession(session: session)
            } else {
                throw error
            }
        }
    }
    
    func upsertLocalWorkoutSession(session: WorkoutSessionModel) throws {
        // Check if session exists locally
        let id = session.id
        do {
            let predicate = #Predicate<WorkoutSessionEntity> { $0.workoutSessionId == id }
            let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate)
            let entities = try mainContext.fetch(descriptor)
            
            if entities.first != nil {
                // Session exists, update it
                try updateLocalWorkoutSession(session: session)
            } else {
                // Session doesn't exist, create it
                try addLocalWorkoutSession(session: session)
            }
        } catch {
            if isSchemaMismatchError(error) {
                rebuildContainer()
                try upsertLocalWorkoutSession(session: session)
            } else {
                throw error
            }
        }
    }
    
    func endLocalWorkoutSession(id: String, at endedAt: Date) throws {
        do {
            let predicate = #Predicate<WorkoutSessionEntity> { $0.workoutSessionId == id }
            let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate)
            let entities = try mainContext.fetch(descriptor)
            guard let entity = entities.first else {
                throw NSError(domain: "SwiftWorkoutSessionPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutSession with id \(id) not found"])
            }
            entity.endedAt = endedAt
            try mainContext.save()
        } catch {
            if isSchemaMismatchError(error) {
                rebuildContainer()
                try endLocalWorkoutSession(id: id, at: endedAt)
            } else {
                throw error
            }
        }
    }
    
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel {
        do {
            let predicate = #Predicate<WorkoutSessionEntity> { $0.workoutSessionId == id }
            let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate)
            let entities = try mainContext.fetch(descriptor)
            guard let entity = entities.first else {
                throw NSError(domain: "SwiftWorkoutSessionPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutSession with id \(id) not found"])
            }
            return entity.toModel()
        } catch {
            if isSchemaMismatchError(error) {
                return WorkoutSessionModel.mocks.first!
            } else {
                throw error
            }
        }
    }
    
    func getLocalWorkoutSessions(ids: [String]) throws -> [WorkoutSessionModel] {
        do {
            let predicate = #Predicate<WorkoutSessionEntity> { ids.contains($0.workoutSessionId) }
            let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate, sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
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
    
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel] {
        do {
            let predicate = #Predicate<WorkoutSessionEntity> { $0.authorId == authorId }
            let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate, sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
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
    
    func getAllLocalWorkoutSessions() throws -> [WorkoutSessionModel] {
        do {
            let descriptor = FetchDescriptor<WorkoutSessionEntity>(sortBy: [SortDescriptor(\.dateCreated, order: .forward)])
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
    
    func deleteLocalWorkoutSession(id: String) throws {
        do {
            let predicate = #Predicate<WorkoutSessionEntity> { $0.workoutSessionId == id }
            let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate)
            let entities = try mainContext.fetch(descriptor)
            guard let entity = entities.first else {
                throw NSError(domain: "SwiftWorkoutSessionPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutSession with id \(id) not found"])
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
    
    func deleteAllLocalWorkoutSessionsForAuthor(authorId: String) throws {
        do {
            let predicate = #Predicate<WorkoutSessionEntity> { $0.authorId == authorId }
            let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate)
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
    
    // MARK: - Active Session Persistence (UserDefaults + SwiftData fallback)
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel? {
        if let sessionId = UserDefaults.standard.string(forKey: activeSessionDefaultsKey) {
            return try? getLocalWorkoutSession(id: sessionId)
        }
        return nil
    }
    
    func setActiveLocalWorkoutSession(_ session: WorkoutSessionModel?) throws {
        if let session {
            UserDefaults.standard.set(session.id, forKey: activeSessionDefaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: activeSessionDefaultsKey)
        }
    }
    
}

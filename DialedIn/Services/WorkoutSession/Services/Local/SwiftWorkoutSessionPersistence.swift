//
//  SwiftWorkoutSessionPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftData
import SwiftUI

@MainActor
struct SwiftWorkoutSessionPersistence: LocalWorkoutSessionPersistence {
    private let container: ModelContainer
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: WorkoutSessionEntity.self, WorkoutExerciseEntity.self, WorkoutSetEntity.self)
    }
    
    func addLocalWorkoutSession(session: WorkoutSessionModel) throws {
        let entity = WorkoutSessionEntity(from: session)
        mainContext.insert(entity)
        try mainContext.save()
    }
    
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws {
        // Avoid capturing non-Sendable 'session' in the predicate closure
        let id = session.id
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
        entity.exercises = session.exercises.map { WorkoutExerciseEntity(from: $0) }
        try mainContext.save()
    }
    
    func endLocalWorkoutSession(id: String, at endedAt: Date) throws {
        let predicate = #Predicate<WorkoutSessionEntity> { $0.workoutSessionId == id }
        let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftWorkoutSessionPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutSession with id \(id) not found"])
        }
        entity.endedAt = endedAt
        try mainContext.save()
    }
    
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel {
        let predicate = #Predicate<WorkoutSessionEntity> { $0.workoutSessionId == id }
        let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftWorkoutSessionPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutSession with id \(id) not found"])
        }
        return entity.toModel()
    }
    
    func getLocalWorkoutSessions(ids: [String]) throws -> [WorkoutSessionModel] {
        let predicate = #Predicate<WorkoutSessionEntity> { ids.contains($0.workoutSessionId) }
        let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate, sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel] {
        let predicate = #Predicate<WorkoutSessionEntity> { $0.authorId == authorId }
        let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate, sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        let limited = limitTo > 0 ? Array(entities.prefix(limitTo)) : entities
        return limited.map { $0.toModel() }
    }
    
    func getAllLocalWorkoutSessions() throws -> [WorkoutSessionModel] {
        let descriptor = FetchDescriptor<WorkoutSessionEntity>(sortBy: [SortDescriptor(\.dateCreated, order: .forward)])
        
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    func deleteLocalWorkoutSession(id: String) throws {
        let predicate = #Predicate<WorkoutSessionEntity> { $0.workoutSessionId == id }
        let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftWorkoutSessionPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutSession with id \(id) not found"])
        }
        mainContext.delete(entity)
        try mainContext.save()
    }
    
    func deleteAllLocalWorkoutSessionsForAuthor(authorId: String) throws {
        let predicate = #Predicate<WorkoutSessionEntity> { $0.authorId == authorId }
        let descriptor = FetchDescriptor<WorkoutSessionEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        for entity in entities { mainContext.delete(entity) }
        try mainContext.save()
    }
    
}

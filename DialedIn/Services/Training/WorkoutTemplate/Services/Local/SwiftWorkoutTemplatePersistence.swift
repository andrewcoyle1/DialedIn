//
//  SwiftWorkoutTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftData
import SwiftUI

@MainActor
struct SwiftWorkoutTemplatePersistence: LocalWorkoutTemplatePersistence {
    private let container: ModelContainer
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: WorkoutTemplateEntity.self)
    }
    
    func addLocalWorkoutTemplate(workout: WorkoutTemplateModel) throws {
        let entity = WorkoutTemplateEntity(from: workout)
        mainContext.insert(entity)
        try mainContext.save()
    }
    
    func getLocalWorkoutTemplate(id: String) throws -> WorkoutTemplateModel {
        let predicate = #Predicate<WorkoutTemplateEntity> { $0.workoutTemplateId == id }
        let descriptor = FetchDescriptor<WorkoutTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftWorkoutTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutTemplate with id \(id) not found"])
        }
        return entity.toModel()
    }
    
    func getLocalWorkoutTemplates(ids: [String]) throws -> [WorkoutTemplateModel] {
        let predicate = #Predicate<WorkoutTemplateEntity> { ids.contains($0.workoutTemplateId) }
        let descriptor = FetchDescriptor<WorkoutTemplateEntity>(predicate: predicate, sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel] {
        let descriptor = FetchDescriptor<WorkoutTemplateEntity>(sortBy: [SortDescriptor(\.name, order: .forward)])
        
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    func bookmarkWorkoutTemplate(id: String, isBookmarked: Bool) throws {
        let predicate = #Predicate<WorkoutTemplateEntity> { $0.workoutTemplateId == id }
        let descriptor = FetchDescriptor<WorkoutTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftWorkoutTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutTemplate with id \(id) not found"])
        }
        entity.bookmarkCount = isBookmarked ? (entity.bookmarkCount ?? 0) + 1 : (entity.bookmarkCount ?? 0) - 1
        try mainContext.save()
    }
    
    func favouriteWorkoutTemplate(id: String, isFavourited: Bool) throws {
        let predicate = #Predicate<WorkoutTemplateEntity> { $0.workoutTemplateId == id }
        let descriptor = FetchDescriptor<WorkoutTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftWorkoutTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutTemplate with id \(id) not found"])
        }
        entity.favouriteCount = isFavourited ? (entity.favouriteCount ?? 0) + 1 : (entity.favouriteCount ?? 0) - 1
        try mainContext.save()
    }
    
    func deleteLocalWorkoutTemplate(id: String) throws {
        let predicate = #Predicate<WorkoutTemplateEntity> { $0.workoutTemplateId == id }
        let descriptor = FetchDescriptor<WorkoutTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftWorkoutTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutTemplate with id \(id) not found"])
        }
        mainContext.delete(entity)
        try mainContext.save()
    }
}

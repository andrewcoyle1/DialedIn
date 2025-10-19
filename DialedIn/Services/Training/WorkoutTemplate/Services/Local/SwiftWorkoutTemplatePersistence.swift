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
    private let storeURL: URL
    let exerciseManager: ExerciseTemplateManager
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    /// Expose model context for seeding operations
    var modelContext: ModelContext {
        mainContext
    }
    
    init(exerciseManager: ExerciseTemplateManager) {
        self.exerciseManager = exerciseManager
        
        // Use the shared App Group container (same as exercises)
        let storeURL: URL = {
            if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) {
                let libraryURL = groupURL.appendingPathComponent("Library", isDirectory: true)
                let appSupportURL = libraryURL.appendingPathComponent("Application Support", isDirectory: true)
                let directory = appSupportURL.appendingPathComponent("DialedIn.WorkoutTemplatesStore", isDirectory: true)
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                return directory.appendingPathComponent("WorkoutTemplates.store")
            } else {
                // Fallback to app's Application Support
                let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let directory = appSupport.appendingPathComponent("DialedIn.WorkoutTemplatesStore", isDirectory: true)
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                return directory.appendingPathComponent("WorkoutTemplates.store")
            }
        }()
        
        self.storeURL = storeURL
        let configuration = ModelConfiguration(url: storeURL)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: WorkoutTemplateEntity.self, configurations: configuration)
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
        return entity.toModel(exerciseManager: exerciseManager)
    }
    
    func getLocalWorkoutTemplates(ids: [String]) throws -> [WorkoutTemplateModel] {
        let predicate = #Predicate<WorkoutTemplateEntity> { ids.contains($0.workoutTemplateId) }
        let descriptor = FetchDescriptor<WorkoutTemplateEntity>(predicate: predicate, sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel(exerciseManager: exerciseManager) }
    }
    
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel] {
        let descriptor = FetchDescriptor<WorkoutTemplateEntity>(sortBy: [SortDescriptor(\.name, order: .forward)])
        
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel(exerciseManager: exerciseManager) }
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

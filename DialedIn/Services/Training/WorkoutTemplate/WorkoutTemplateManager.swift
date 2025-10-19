//
//  ExerciseTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@MainActor
@Observable
class WorkoutTemplateManager {
    
    private let local: LocalWorkoutTemplatePersistence
    private let remote: RemoteWorkoutTemplateService
    private var seedingManager: WorkoutSeedingManager?
    private let exerciseManager: ExerciseTemplateManager
    
    init(services: WorkoutTemplateServices, exerciseManager: ExerciseTemplateManager) {
        self.remote = services.remote
        self.local = services.local
        self.exerciseManager = exerciseManager
        
        // Initialize seeding manager if using production services
        if let swiftPersistence = services.local as? SwiftWorkoutTemplatePersistence {
            self.seedingManager = WorkoutSeedingManager(
                modelContext: swiftPersistence.modelContext,
                exerciseManager: exerciseManager
            )
            
            // Seed workouts on initialization
            Task {
                try? await self.seedingManager?.seedWorkoutsIfNeeded()
            }
        }
    }
    
    func addLocalWorkoutTemplate(workout: WorkoutTemplateModel) async throws {
        try local.addLocalWorkoutTemplate(workout: workout)
        try await remote.incrementWorkoutTemplateInteraction(id: workout.id)
    }
    
    func getLocalWorkoutTemplate(id: String) throws -> WorkoutTemplateModel {
        try local.getLocalWorkoutTemplate(id: id)
    }
    
    func getLocalWorkoutTemplates(ids: [String]) throws -> [WorkoutTemplateModel] {
        try local.getLocalWorkoutTemplates(ids: ids)
    }
    
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel] {
        try local.getAllLocalWorkoutTemplates()
    }
    
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws {
        try await remote.createWorkoutTemplate(workout: workout, image: image)
    }
    
    func updateWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws {
        try await remote.updateWorkoutTemplate(workout: workout, image: image)
    }
    
    func deleteWorkoutTemplate(id: String) async throws {
        try await remote.deleteWorkoutTemplate(id: id)
        // Also delete local copy if it exists
        do {
            try local.deleteLocalWorkoutTemplate(id: id)
        } catch {
            // Ignore if local copy doesn't exist
            print("⚠️ No local workout template to delete for \(id)")
        }
    }
    
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel {
        // Try local first (for system workouts), then remote
        if let localTemplate = try? local.getLocalWorkoutTemplate(id: id) {
            return localTemplate
        }
        return try await remote.getWorkoutTemplate(id: id)
    }
    
    func get(id: String) async -> WorkoutTemplateModel? {
        // Non-throwing version for convenience
        if let localTemplate = try? local.getLocalWorkoutTemplate(id: id) {
            return localTemplate
        }
        return try? await remote.getWorkoutTemplate(id: id)
    }
    
    func getWorkoutTemplates(ids: [String], limitTo: Int = 20) async throws -> [WorkoutTemplateModel] {
        try await remote.getWorkoutTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getWorkoutTemplatesByName(name: String) async throws -> [WorkoutTemplateModel] {
        try await remote.getWorkoutTemplatesByName(name: name)
    }
    
    func getWorkoutTemplatesForAuthor(authorId: String) async throws -> [WorkoutTemplateModel] {
        try await remote.getWorkoutTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopWorkoutTemplatesByClicks(limitTo: Int = 10) async throws -> [WorkoutTemplateModel] {
        try await remote.getTopWorkoutTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementWorkoutTemplateInteraction(id: String) async throws {
        try await remote.incrementWorkoutTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromWorkoutTemplate(id: String) async throws {
        try await remote.removeAuthorIdFromWorkoutTemplate(id: id)
    }
    
    func removeAuthorIdFromAllWorkoutTemplates(id: String) async throws {
        try await remote.removeAuthorIdFromAllWorkoutTemplates(id: id)
    }
    
    func bookmarkWorkoutTemplate(id: String, isBookmarked: Bool) async throws {
        try await remote.bookmarkWorkoutTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteWorkoutTemplate(id: String, isFavourited: Bool) async throws {
        try await remote.favouriteWorkoutTemplate(id: id, isFavourited: isFavourited)
    }
}

//
//  WorkoutTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@Observable
class WorkoutTemplateManager: BaseTemplateManager<WorkoutTemplateModel>, WorkoutTemplateResolver {
    
    private let local: LocalWorkoutTemplatePersistence
    private let remote: RemoteWorkoutTemplateService
    private var seedingManager: WorkoutSeedingManager?
    private let exerciseManager: ExerciseTemplateManager
    
    init(services: WorkoutTemplateServices, exerciseManager: ExerciseTemplateManager) {
        self.exerciseManager = exerciseManager
        self.local = services.local
        self.remote = services.remote
        super.init(
            addLocal: { try services.local.addLocalWorkoutTemplate(workout: $0) },
            getLocal: { try services.local.getLocalWorkoutTemplate(id: $0) },
            getLocalMany: { try services.local.getLocalWorkoutTemplates(ids: $0) },
            getAllLocal: { try services.local.getAllLocalWorkoutTemplates() },
            deleteLocal: { try services.local.deleteLocalWorkoutTemplate(id: $0) },
            createRemote: { try await services.remote.createWorkoutTemplate(workout: $0, image: $1) },
            updateRemote: { try await services.remote.updateWorkoutTemplate(workout: $0, image: $1) },
            deleteRemote: { try await services.remote.deleteWorkoutTemplate(id: $0) },
            getRemote: { try await services.remote.getWorkoutTemplate(id: $0) },
            getRemoteMany: { try await services.remote.getWorkoutTemplates(ids: $0, limitTo: $1) },
            getByNameRemote: { try await services.remote.getWorkoutTemplatesByName(name: $0) },
            getForAuthorRemote: { try await services.remote.getWorkoutTemplatesForAuthor(authorId: $0) },
            getTopByClicksRemote: { try await services.remote.getTopWorkoutTemplatesByClicks(limitTo: $0) },
            incrementRemote: { try await services.remote.incrementWorkoutTemplateInteraction(id: $0) },
            removeAuthorIdRemote: { try await services.remote.removeAuthorIdFromWorkoutTemplate(id: $0) },
            removeAuthorIdFromAllRemote: { try await services.remote.removeAuthorIdFromAllWorkoutTemplates(id: $0) },
            bookmarkRemote: { try await services.remote.bookmarkWorkoutTemplate(id: $0, isBookmarked: $1) },
            favouriteRemote: { try await services.remote.favouriteWorkoutTemplate(id: $0, isFavourited: $1) }
        )
        
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
    
    // MARK: - Override for special get behavior
    
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel {
        // Try local first (for system workouts), then remote
        if let localTemplate = try? local.getLocalWorkoutTemplate(id: id) {
            return localTemplate
        }
        return try await getTemplate(id: id)
    }
    
    func get(id: String) async -> WorkoutTemplateModel? {
        // Non-throwing version for convenience
        if let localTemplate = try? local.getLocalWorkoutTemplate(id: id) {
            return localTemplate
        }
        return try? await getTemplate(id: id)
    }
    
    func deleteWorkoutTemplate(id: String) async throws {
        try await deleteTemplate(id: id)
        // Also delete local copy if it exists
        do {
            try local.deleteLocalWorkoutTemplate(id: id)
        } catch {
            // Ignore if local copy doesn't exist
            print("⚠️ No local workout template to delete for \(id)")
        }
    }
    
    // MARK: - Method Aliases for Backward Compatibility
    
    func addLocalWorkoutTemplate(workout: WorkoutTemplateModel) async throws {
        try await addLocalTemplate(workout)
    }
    
    func getLocalWorkoutTemplate(id: String) throws -> WorkoutTemplateModel {
        try getLocalTemplate(id: id)
    }
    
    func getLocalWorkoutTemplates(ids: [String]) throws -> [WorkoutTemplateModel] {
        try getLocalTemplates(ids: ids)
    }
    
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel] {
        try getAllLocalTemplates()
    }
    
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws {
        try await createTemplate(workout, image: image)
    }
    
    func updateWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws {
        try await updateTemplate(workout, image: image)
    }
    
    func getWorkoutTemplates(ids: [String], limitTo: Int = 20) async throws -> [WorkoutTemplateModel] {
        try await getTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getWorkoutTemplatesByName(name: String) async throws -> [WorkoutTemplateModel] {
        try await getTemplatesByName(name: name)
    }
    
    func getWorkoutTemplatesForAuthor(authorId: String) async throws -> [WorkoutTemplateModel] {
        try await getTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopWorkoutTemplatesByClicks(limitTo: Int = 10) async throws -> [WorkoutTemplateModel] {
        try await getTopTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementWorkoutTemplateInteraction(id: String) async throws {
        try await incrementTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromWorkoutTemplate(id: String) async throws {
        try await removeAuthorIdFromTemplate(id: id)
    }
    
    func removeAuthorIdFromAllWorkoutTemplates(id: String) async throws {
        try await removeAuthorIdFromAllTemplates(id: id)
    }
    
    func bookmarkWorkoutTemplate(id: String, isBookmarked: Bool) async throws {
        try await bookmarkTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteWorkoutTemplate(id: String, isFavourited: Bool) async throws {
        try await remote.favouriteWorkoutTemplate(id: id, isFavourited: isFavourited)
    }
}
 

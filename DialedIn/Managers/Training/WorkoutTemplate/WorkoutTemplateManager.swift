//
//  WorkoutTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutTemplateManager {
    
    private let local: LocalWorkoutTemplatePersistence
    private let remote: RemoteWorkoutTemplateService
    private let exerciseManager: ExerciseTemplateManager
    
    init(services: WorkoutTemplateServices, exerciseManager: ExerciseTemplateManager) {
        self.exerciseManager = exerciseManager
        self.local = services.local
        self.remote = services.remote
    }
    
    // MARK: - Override for special get behavior
    
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel {
        // Try local first (for system workouts), then remote
        if let localTemplate = try? local.getLocalWorkoutTemplate(id: id) {
            return localTemplate
        }
        return try await remote.getWorkoutTemplate(id: id)
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
    
    // MARK: - Method Aliases for Backward Compatibility
    
    func addLocalWorkoutTemplate(workout: WorkoutTemplateModel) async throws {
        try local.addLocalWorkoutTemplate(workout: workout)
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
 
extension CoreInteractor {
    // MARK: WorkoutTemplateManager
    
    func addLocalWorkoutTemplate(workout: WorkoutTemplateModel) async throws {
        try await workoutTemplateManager.incrementWorkoutTemplateInteraction(id: workout.id)
    }
    
    func getLocalWorkoutTemplate(id: String) throws -> WorkoutTemplateModel {
        try workoutTemplateManager.getLocalWorkoutTemplate(id: id)
    }
    
    func getLocalWorkoutTemplates(ids: [String]) throws -> [WorkoutTemplateModel] {
        try workoutTemplateManager.getLocalWorkoutTemplates(ids: ids)
    }
    
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel] {
        try workoutTemplateManager.getAllLocalWorkoutTemplates()
    }
    
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws {
        try await workoutTemplateManager.createWorkoutTemplate(workout: workout, image: image)
    }
    
    func updateWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws {
        try await workoutTemplateManager.updateWorkoutTemplate(workout: workout, image: image)
    }
    
    func deleteWorkoutTemplate(id: String) async throws {
        try await workoutTemplateManager.deleteWorkoutTemplate(id: id)
    }
    
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel {
        try await workoutTemplateManager.getWorkoutTemplate(id: id)
    }
    
    func get(id: String) async -> WorkoutTemplateModel? {
        return try? await workoutTemplateManager.getWorkoutTemplate(id: id)
    }
    
    func getWorkoutTemplates(ids: [String], limitTo: Int = 20) async throws -> [WorkoutTemplateModel] {
        try await workoutTemplateManager.getWorkoutTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getWorkoutTemplatesByName(name: String) async throws -> [WorkoutTemplateModel] {
        try await workoutTemplateManager.getWorkoutTemplatesByName(name: name)
    }
    
    func getWorkoutTemplatesForAuthor(authorId: String) async throws -> [WorkoutTemplateModel] {
        try await workoutTemplateManager.getWorkoutTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopWorkoutTemplatesByClicks(limitTo: Int = 10) async throws -> [WorkoutTemplateModel] {
        try await workoutTemplateManager.getTopWorkoutTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementWorkoutTemplateInteraction(id: String) async throws {
        try await workoutTemplateManager.incrementWorkoutTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromWorkoutTemplate(id: String) async throws {
        try await workoutTemplateManager.removeAuthorIdFromWorkoutTemplate(id: id)
    }
    
    func removeAuthorIdFromAllWorkoutTemplates(id: String) async throws {
        try await workoutTemplateManager.removeAuthorIdFromAllWorkoutTemplates(id: id)
    }
    
    func bookmarkWorkoutTemplate(id: String, isBookmarked: Bool) async throws {
        try await workoutTemplateManager.bookmarkWorkoutTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteWorkoutTemplate(id: String, isFavourited: Bool) async throws {
        try await workoutTemplateManager.favouriteWorkoutTemplate(id: id, isFavourited: isFavourited)
    }

}

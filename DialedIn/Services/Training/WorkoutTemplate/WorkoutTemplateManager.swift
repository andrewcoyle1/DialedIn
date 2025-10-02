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
    
    init(services: WorkoutTemplateServices) {
        self.remote = services.remote
        self.local = services.local
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
    
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel {
        try await remote.getWorkoutTemplate(id: id)
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

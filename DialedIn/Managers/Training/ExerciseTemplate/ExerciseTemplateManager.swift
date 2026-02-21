//
//  ExerciseTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@Observable
@MainActor
class ExerciseTemplateManager {
    
    private let local: LocalExercisePersistence
    private let remote: RemoteExerciseTemplateService

    init(services: ExerciseTemplateServices) {
        self.local = services.local
        self.remote = services.remote
    }
    
    // MARK: - Specialized Methods
    
    func getSystemExerciseTemplates() throws -> [ExerciseModel] {
        try local.getSystemExercises()
    }
    
    // MARK: - Method Aliases for Backward Compatibility
    
    func addLocalExerciseTemplate(exercise: ExerciseModel) throws {
        try local.addLocalExercise(exercise: exercise)
    }
    
    func getLocalExerciseTemplate(id: String) throws -> ExerciseModel {
        try local.getLocalExercise(id: id)
    }
    
    func getLocalExerciseTemplates(ids: [String]) throws -> [ExerciseModel] {
        try local.getLocalExercises(ids: ids)
    }
    
    func getAllLocalExerciseTemplates() throws -> [ExerciseModel] {
        try local.getAllLocalExercises()
    }
    
    func createExerciseTemplate(exercise: ExerciseModel, image: PlatformImage?) async throws {
        try await remote.createExerciseTemplate(exercise: exercise, image: image)
    }
    
    func getExerciseTemplate(id: String) async throws -> ExerciseModel {
        let exercises = try await getExerciseTemplates(ids: [id], limitTo: 1)
        guard let exercise = exercises.first else {
            throw NSError(domain: "ExerciseTemplateManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Exercise with id \(id) not found"])
        }
        return exercise
    }
    
    func getExerciseTemplates(ids: [String], limitTo: Int = 20) async throws -> [ExerciseModel] {
        // Try local first (covers system exercises from PrebuiltExercises.json).
        // Fall back to remote for any IDs not found locally (avoids Firebase decode errors for missing docs).
        let localExercises = (try? await MainActor.run { try local.getLocalExercises(ids: ids) }) ?? []
        let foundIds = Set(localExercises.map(\.id))
        let missingIds = ids.filter { !foundIds.contains($0) }

        guard !missingIds.isEmpty else {
            return Array(localExercises.prefix(limitTo))
        }

        let remoteExercises = try await remote.getExerciseTemplates(ids: missingIds, limitTo: missingIds.count)
        let merged = localExercises + remoteExercises
        return Array(merged.prefix(limitTo))
    }
    
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseModel] {
        try await remote.getExerciseTemplatesByName(name: name)
    }
    
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseModel] {
        try await remote.getExerciseTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopExerciseTemplatesByClicks(limitTo: Int = 10) async throws -> [ExerciseModel] {
        try await remote.getTopExerciseTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementExerciseTemplateInteraction(id: String) async throws {
        try await remote.incrementExerciseTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromExerciseTemplate(id: String) async throws {
        try await remote.removeAuthorIdFromExerciseTemplate(id: id)
    }
    
    func removeAuthorIdFromAllExerciseTemplates(id: String) async throws {
        try await remote.removeAuthorIdFromAllExerciseTemplates(id: id)
    }
    
    func bookmarkExerciseTemplate(id: String, isBookmarked: Bool) async throws {
        try await remote.bookmarkExerciseTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteExerciseTemplate(id: String, isFavourited: Bool) async throws {
        try await remote.favouriteExerciseTemplate(id: id, isFavourited: isFavourited)
    }
}

//
//  ExerciseTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@MainActor
@Observable
class ExerciseTemplateManager {
    
    private let local: LocalExerciseTemplatePersistence
    private let remote: RemoteExerciseTemplateService
    
    init(services: ExerciseTemplateServices) {
        self.remote = services.remote
        self.local = services.local
    }
    
    func addLocalExerciseTemplate(exercise: ExerciseTemplateModel) async throws {
        try local.addLocalExerciseTemplate(exercise: exercise)
        try await remote.incrementExerciseTemplateInteraction(id: exercise.id)
    }
    
    func getLocalExerciseTemplate(id: String) throws -> ExerciseTemplateModel {
        try local.getLocalExerciseTemplate(id: id)
    }
    
    func getLocalExerciseTemplates(ids: [String]) throws -> [ExerciseTemplateModel] {
        try local.getLocalExerciseTemplates(ids: ids)
    }
    
    func getAllLocalExerciseTemplates() throws -> [ExerciseTemplateModel] {
        try local.getAllLocalExerciseTemplates()
    }
    
    func createExerciseTemplate(exercise: ExerciseTemplateModel, image: PlatformImage?) async throws {
        try await remote.createExerciseTemplate(exercise: exercise, image: image)
    }
    
    func getExerciseTemplate(id: String) async throws -> ExerciseTemplateModel {
        try await remote.getExerciseTemplate(id: id)
    }
    
    func getExerciseTemplates(ids: [String], limitTo: Int = 20) async throws -> [ExerciseTemplateModel] {
        try await remote.getExerciseTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseTemplateModel] {
        try await remote.getExerciseTemplatesByName(name: name)
    }
    
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseTemplateModel] {
        try await remote.getExerciseTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopExerciseTemplatesByClicks(limitTo: Int = 10) async throws -> [ExerciseTemplateModel] {
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

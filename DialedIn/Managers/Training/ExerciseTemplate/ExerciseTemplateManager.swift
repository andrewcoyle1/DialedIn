//
//  ExerciseTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@Observable
class ExerciseTemplateManager: BaseTemplateManager<ExerciseModel> {
    
    private let local: LocalExercisePersistence
    private let remote: RemoteExerciseTemplateService

    init(services: ExerciseTemplateServices) {
        self.local = services.local
        self.remote = services.remote
        
        super.init(
            addLocal: { try services.local.addLocalExercise(exercise: $0) },
            getLocal: { try services.local.getLocalExercise(id: $0) },
            getLocalMany: { try services.local.getLocalExercises(ids: $0) },
            getAllLocal: { try services.local.getAllLocalExercises() },
            deleteLocal: nil,
            createRemote: { try await services.remote.createExerciseTemplate(exercise: $0, image: $1) },
            updateRemote: nil,
            deleteRemote: nil,
            getRemote: { try await services.remote.getExerciseTemplate(id: $0) },
            getRemoteMany: { try await services.remote.getExerciseTemplates(ids: $0, limitTo: $1) },
            getByNameRemote: { try await services.remote.getExerciseTemplatesByName(name: $0) },
            getForAuthorRemote: { try await services.remote.getExerciseTemplatesForAuthor(authorId: $0) },
            getTopByClicksRemote: { try await services.remote.getTopExerciseTemplatesByClicks(limitTo: $0) },
            incrementRemote: { try await services.remote.incrementExerciseTemplateInteraction(id: $0) },
            removeAuthorIdRemote: { try await services.remote.removeAuthorIdFromExerciseTemplate(id: $0) },
            removeAuthorIdFromAllRemote: { try await services.remote.removeAuthorIdFromAllExerciseTemplates(id: $0) },
            bookmarkRemote: { try await services.remote.bookmarkExerciseTemplate(id: $0, isBookmarked: $1) },
            favouriteRemote: { try await services.remote.favouriteExerciseTemplate(id: $0, isFavourited: $1) }
        )
    }
    
    // MARK: - Specialized Methods
    
    func getSystemExerciseTemplates() throws -> [ExerciseModel] {
        try local.getSystemExercises()
    }
    
    // MARK: - Method Aliases for Backward Compatibility
    
    func addLocalExerciseTemplate(exercise: ExerciseModel) async throws {
        try await addLocalTemplate(exercise)
    }
    
    func getLocalExerciseTemplate(id: String) throws -> ExerciseModel {
        try getLocalTemplate(id: id)
    }
    
    func getLocalExerciseTemplates(ids: [String]) throws -> [ExerciseModel] {
        try getLocalTemplates(ids: ids)
    }
    
    func getAllLocalExerciseTemplates() throws -> [ExerciseModel] {
        try getAllLocalTemplates()
    }
    
    func createExerciseTemplate(exercise: ExerciseModel, image: PlatformImage?) async throws {
        try await createTemplate(exercise, image: image)
    }
    
    func getExerciseTemplate(id: String) async throws -> ExerciseModel {
        try await getTemplate(id: id)
    }
    
    func getExerciseTemplates(ids: [String], limitTo: Int = 20) async throws -> [ExerciseModel] {
        try await getTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseModel] {
        try await getTemplatesByName(name: name)
    }
    
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseModel] {
        try await getTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopExerciseTemplatesByClicks(limitTo: Int = 10) async throws -> [ExerciseModel] {
        try await getTopTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementExerciseTemplateInteraction(id: String) async throws {
        try await incrementTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromExerciseTemplate(id: String) async throws {
        try await removeAuthorIdFromTemplate(id: id)
    }
    
    func removeAuthorIdFromAllExerciseTemplates(id: String) async throws {
        try await removeAuthorIdFromAllTemplates(id: id)
    }
    
    func bookmarkExerciseTemplate(id: String, isBookmarked: Bool) async throws {
        try await bookmarkTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteExerciseTemplate(id: String, isFavourited: Bool) async throws {
        try await favouriteTemplate(id: id, isFavourited: isFavourited)
    }
}

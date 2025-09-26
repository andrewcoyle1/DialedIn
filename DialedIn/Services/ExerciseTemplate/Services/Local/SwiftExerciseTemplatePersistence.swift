//
//  SwiftExerciseTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftData
import SwiftUI

@MainActor
struct SwiftExerciseTemplatePersistence: LocalExerciseTemplatePersistence {
    private let container: ModelContainer
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: ExerciseTemplateEntity.self)
    }
    
    func addLocalExerciseTemplate(exercise: ExerciseTemplateModel) throws {
        let entity = ExerciseTemplateEntity(from: exercise)
        mainContext.insert(entity)
        try mainContext.save()
    }
    
    func getLocalExerciseTemplate(id: String) throws -> ExerciseTemplateModel {
        let predicate = #Predicate<ExerciseTemplateEntity> { $0.exerciseTemplateId == id }
        let descriptor = FetchDescriptor<ExerciseTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftExerciseTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "ExerciseTemplate with id \(id) not found"])
        }
        return entity.toModel()
    }
    
    func getLocalExerciseTemplates(ids: [String]) throws -> [ExerciseTemplateModel] {
        let predicate = #Predicate<ExerciseTemplateEntity> { ids.contains($0.exerciseTemplateId) }
        let descriptor = FetchDescriptor<ExerciseTemplateEntity>(predicate: predicate, sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    func getAllLocalExerciseTemplates() throws -> [ExerciseTemplateModel] {
        let descriptor = FetchDescriptor<ExerciseTemplateEntity>(sortBy: [SortDescriptor(\.name, order: .forward)])
        
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    func bookmarkExerciseTemplate(id: String, isBookmarked: Bool) throws {
        let predicate = #Predicate<ExerciseTemplateEntity> { $0.exerciseTemplateId == id }
        let descriptor = FetchDescriptor<ExerciseTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftExerciseTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "ExerciseTemplate with id \(id) not found"])
        }
        entity.bookmarkCount = isBookmarked ? (entity.bookmarkCount ?? 0) + 1 : (entity.bookmarkCount ?? 0) - 1
        try mainContext.save()
    }
    
    func favouriteExerciseTemplate(id: String, isFavourited: Bool) throws {
        let predicate = #Predicate<ExerciseTemplateEntity> { $0.exerciseTemplateId == id }
        let descriptor = FetchDescriptor<ExerciseTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftExerciseTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "ExerciseTemplate with id \(id) not found"])
        }
        entity.favouriteCount = isFavourited ? (entity.favouriteCount ?? 0) + 1 : (entity.favouriteCount ?? 0) - 1
        try mainContext.save()
    }
}

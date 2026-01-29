//
//  SwiftIngredientTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftData
import SwiftUI

@MainActor
struct SwiftIngredientTemplatePersistence: LocalIngredientTemplatePersistence {
    private let container: ModelContainer
    
    @MainActor
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: IngredientTemplateEntity.self)
    }
    
    @MainActor
    func addLocalIngredientTemplate(ingredient: IngredientTemplateModel) throws {
        let entity = IngredientTemplateEntity(from: ingredient)
        mainContext.insert(entity)
        try mainContext.save()
    }
    
    @MainActor
    func getLocalIngredientTemplate(id: String) throws -> IngredientTemplateModel {
        let predicate = #Predicate<IngredientTemplateEntity> { $0.ingredientTemplateId == id }
        let descriptor = FetchDescriptor<IngredientTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftIngredientTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "IngredientTemplate with id \(id) not found"])
        }
        return entity.toModel()
    }
    
    @MainActor
    func getLocalIngredientTemplates(ids: [String]) throws -> [IngredientTemplateModel] {
        let predicate = #Predicate<IngredientTemplateEntity> { ids.contains($0.ingredientTemplateId) }
        let descriptor = FetchDescriptor<IngredientTemplateEntity>(predicate: predicate, sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    @MainActor
    func getAllLocalIngredientTemplates() throws -> [IngredientTemplateModel] {
        let descriptor = FetchDescriptor<IngredientTemplateEntity>(sortBy: [SortDescriptor(\.name, order: .forward)])
        
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    @MainActor
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) throws {
        let predicate = #Predicate<IngredientTemplateEntity> { $0.ingredientTemplateId == id }
        let descriptor = FetchDescriptor<IngredientTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftIngredientTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "IngredientTemplate with id \(id) not found"])
        }
        entity.bookmarkCount = isBookmarked ? (entity.bookmarkCount ?? 0) + 1 : (entity.bookmarkCount ?? 0) - 1
        try mainContext.save()
    }
    
    @MainActor
    func favouriteIngredientTemplate(id: String, isFavourited: Bool) throws {
        let predicate = #Predicate<IngredientTemplateEntity> { $0.ingredientTemplateId == id }
        let descriptor = FetchDescriptor<IngredientTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftIngredientTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "IngredientTemplate with id \(id) not found"])
        }
        entity.favouriteCount = isFavourited ? (entity.favouriteCount ?? 0) + 1 : (entity.favouriteCount ?? 0) - 1
        try mainContext.save()
    }
}

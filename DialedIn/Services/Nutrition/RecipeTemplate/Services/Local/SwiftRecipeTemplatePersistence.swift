//
//  SwiftRecipeTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftData
import SwiftUI

@MainActor
struct SwiftRecipeTemplatePersistence: LocalRecipeTemplatePersistence {
    private let container: ModelContainer
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: RecipeTemplateEntity.self)
    }
    
    func addLocalRecipeTemplate(recipe: RecipeTemplateModel) throws {
        let entity = RecipeTemplateEntity(from: recipe)
        mainContext.insert(entity)
        try mainContext.save()
    }
    
    func getLocalRecipeTemplate(id: String) throws -> RecipeTemplateModel {
        let predicate = #Predicate<RecipeTemplateEntity> { $0.recipeTemplateId == id }
        let descriptor = FetchDescriptor<RecipeTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftRecipeTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "RecipeTemplate with id \(id) not found"])
        }
        return entity.toModel()
    }
    
    func getLocalRecipeTemplates(ids: [String]) throws -> [RecipeTemplateModel] {
        let predicate = #Predicate<RecipeTemplateEntity> { ids.contains($0.recipeTemplateId) }
        let descriptor = FetchDescriptor<RecipeTemplateEntity>(predicate: predicate, sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    func getAllLocalRecipeTemplates() throws -> [RecipeTemplateModel] {
        let descriptor = FetchDescriptor<RecipeTemplateEntity>(sortBy: [SortDescriptor(\.name, order: .forward)])
        
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    func bookmarkRecipeTemplate(id: String, isBookmarked: Bool) throws {
        let predicate = #Predicate<RecipeTemplateEntity> { $0.recipeTemplateId == id }
        let descriptor = FetchDescriptor<RecipeTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftRecipeTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "RecipeTemplate with id \(id) not found"])
        }
        entity.bookmarkCount = isBookmarked ? (entity.bookmarkCount ?? 0) + 1 : (entity.bookmarkCount ?? 0) - 1
        try mainContext.save()
    }
    
    func favouriteRecipeTemplate(id: String, isFavourited: Bool) throws {
        let predicate = #Predicate<RecipeTemplateEntity> { $0.recipeTemplateId == id }
        let descriptor = FetchDescriptor<RecipeTemplateEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftRecipeTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "RecipeTemplate with id \(id) not found"])
        }
        entity.favouriteCount = isFavourited ? (entity.favouriteCount ?? 0) + 1 : (entity.favouriteCount ?? 0) - 1
        try mainContext.save()
    }
}

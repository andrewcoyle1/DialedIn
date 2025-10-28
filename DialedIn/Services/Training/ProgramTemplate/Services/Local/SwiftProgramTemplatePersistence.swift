//
//  SwiftProgramTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation
import SwiftData
// Note: Keep SwiftData predicates scoped to entity properties and plain values.
// Mixing model key paths into predicates can cause Sendable/key path issues in macro-generated code.

class SwiftProgramTemplatePersistence: LocalProgramTemplatePersistence {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Seed built-in templates if not already present
        if getAll().isEmpty {
            seedBuiltInTemplates()
        }
    }
    
    func getAll() -> [ProgramTemplateModel] {
        let descriptor = FetchDescriptor<ProgramTemplateEntity>()
        do {
            let entities = try modelContext.fetch(descriptor)
            return entities.compactMap { $0.toModel() }
        } catch {
            print("Error fetching program templates: \(error)")
            return []
        }
    }
    
    func get(id: String) -> ProgramTemplateModel? {
        let idValue: String = id
        var descriptor = FetchDescriptor<ProgramTemplateEntity>(
            predicate: #Predicate<ProgramTemplateEntity> { entity in
                entity.id == idValue
            }
        )
        descriptor.fetchLimit = 1

        do {
            let entities = try modelContext.fetch(descriptor)
            return entities.first?.toModel()
        } catch {
            print("Error fetching program template: \(error)")
            return nil
        }
    }
    
    func save(_ template: ProgramTemplateModel) throws {
        // Check if exists
        if get(id: template.id) != nil {
            // Update
            let templateId: String = template.id
            var descriptor = FetchDescriptor<ProgramTemplateEntity>(
                predicate: #Predicate<ProgramTemplateEntity> { entity in
                    entity.id == templateId
                }
            )
            descriptor.fetchLimit = 1
            
            if let entity = try modelContext.fetch(descriptor).first {
                entity.update(from: template)
            }
        } else {
            // Insert
            let entity = ProgramTemplateEntity(from: template)
            modelContext.insert(entity)
        }
        
        try modelContext.save()
    }
    
    func delete(id: String) throws {
        let idValue: String = id
        var descriptor = FetchDescriptor<ProgramTemplateEntity>(
            predicate: #Predicate<ProgramTemplateEntity> { entity in
                entity.id == idValue
            }
        )
        descriptor.fetchLimit = 1
        
        if let entity = try modelContext.fetch(descriptor).first {
            modelContext.delete(entity)
            try modelContext.save()
        }
    }
    
    func getBuiltInTemplates() -> [ProgramTemplateModel] {
        ProgramTemplateModel.builtInTemplates
    }
    
    private func seedBuiltInTemplates() {
        for template in ProgramTemplateModel.builtInTemplates {
            try? save(template)
        }
    }
}

// MARK: - SwiftData Entity
@Model
class ProgramTemplateEntity {
    @Attribute(.unique) var id: String
    var name: String
    var templateDescription: String
    var duration: Int
    var difficultyRaw: String
    var focusAreasRaw: [String]
    var weekTemplatesData: Data?
    var isPublic: Bool
    var authorId: String?
    var createdAt: Date
    var modifiedAt: Date
    
    init(
        id: String,
        name: String,
        templateDescription: String,
        duration: Int,
        difficultyRaw: String,
        focusAreasRaw: [String],
        weekTemplatesData: Data?,
        isPublic: Bool,
        authorId: String?,
        createdAt: Date,
        modifiedAt: Date
    ) {
        self.id = id
        self.name = name
        self.templateDescription = templateDescription
        self.duration = duration
        self.difficultyRaw = difficultyRaw
        self.focusAreasRaw = focusAreasRaw
        self.weekTemplatesData = weekTemplatesData
        self.isPublic = isPublic
        self.authorId = authorId
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
    
    convenience init(from model: ProgramTemplateModel) {
        let weekData = try? JSONEncoder().encode(model.weekTemplates)
        self.init(
            id: model.id,
            name: model.name,
            templateDescription: model.description,
            duration: model.duration,
            difficultyRaw: model.difficulty.rawValue,
            focusAreasRaw: model.focusAreas.map { $0.rawValue },
            weekTemplatesData: weekData,
            isPublic: model.isPublic,
            authorId: model.authorId,
            createdAt: model.createdAt,
            modifiedAt: model.modifiedAt
        )
    }
    
    @MainActor
    func toModel() -> ProgramTemplateModel? {
        guard let difficulty = DifficultyLevel(rawValue: difficultyRaw) else { return nil }
        
        let focusAreas = focusAreasRaw.compactMap { FocusArea(rawValue: $0) }
        
        var weekTemplates: [WeekTemplate] = []
        if let data = weekTemplatesData {
            weekTemplates = (try? JSONDecoder().decode([WeekTemplate].self, from: data)) ?? []
        }
        
        return ProgramTemplateModel(
            id: id,
            name: name,
            description: templateDescription,
            duration: duration,
            difficulty: difficulty,
            focusAreas: focusAreas,
            weekTemplates: weekTemplates,
            isPublic: isPublic,
            authorId: authorId,
            createdAt: createdAt,
            modifiedAt: modifiedAt
        )
    }
    
    func update(from model: ProgramTemplateModel) {
        self.name = model.name
        self.templateDescription = model.description
        self.duration = model.duration
        self.difficultyRaw = model.difficulty.rawValue
        self.focusAreasRaw = model.focusAreas.map { $0.rawValue }
        self.weekTemplatesData = try? JSONEncoder().encode(model.weekTemplates)
        self.isPublic = model.isPublic
        self.modifiedAt = model.modifiedAt
    }
}

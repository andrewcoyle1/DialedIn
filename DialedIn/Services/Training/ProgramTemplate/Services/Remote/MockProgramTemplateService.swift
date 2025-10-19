//
//  MockProgramTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation

class MockProgramTemplateService: RemoteProgramTemplateService {
    
    private var templates: [String: ProgramTemplateModel] = [:]
    
    init() {
        // Seed with built-in templates
        for template in ProgramTemplateModel.builtInTemplates {
            templates[template.id] = template
        }
    }
    
    func fetchAll() async throws -> [ProgramTemplateModel] {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
        return Array(templates.values).sorted { $0.name < $1.name }
    }
    
    func fetch(id: String) async throws -> ProgramTemplateModel {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3s delay
        guard let template = templates[id] else {
            throw ProgramTemplateError.notFound
        }
        return template
    }
    
    func create(_ template: ProgramTemplateModel) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        templates[template.id] = template
    }
    
    func update(_ template: ProgramTemplateModel) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        guard templates[template.id] != nil else {
            throw ProgramTemplateError.notFound
        }
        templates[template.id] = template
    }
    
    func delete(id: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        guard templates[id] != nil else {
            throw ProgramTemplateError.notFound
        }
        templates.removeValue(forKey: id)
    }
    
    func fetchPublicTemplates() async throws -> [ProgramTemplateModel] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return templates.values.filter { $0.isPublic }.sorted { $0.name < $1.name }
    }
}

enum ProgramTemplateError: Error {
    case notFound
    case invalidData
    case networkError
}

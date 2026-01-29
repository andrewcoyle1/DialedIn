//
//  MockProgramTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation

class MockProgramTemplatePersistence: LocalProgramTemplatePersistence {
    
    private var templates: [String: ProgramTemplateModel] = [:]
    
    init() {
        // Seed with built-in templates
        for template in ProgramTemplateModel.builtInTemplates {
            templates[template.id] = template
        }
    }
    
    func getAll() -> [ProgramTemplateModel] {
        Array(templates.values).sorted { $0.name < $1.name }
    }
    
    func get(id: String) -> ProgramTemplateModel? {
        templates[id]
    }
    
    func save(_ template: ProgramTemplateModel) throws {
        templates[template.id] = template
    }
    
    func delete(id: String) throws {
        templates.removeValue(forKey: id)
    }
    
    func getBuiltInTemplates() -> [ProgramTemplateModel] {
        ProgramTemplateModel.builtInTemplates
    }
}

//
//  LocalProgramTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

protocol LocalProgramTemplatePersistence {
    func getAll() -> [ProgramTemplateModel]
    func get(id: String) -> ProgramTemplateModel?
    func save(_ template: ProgramTemplateModel) throws
    func delete(id: String) throws
    func getBuiltInTemplates() -> [ProgramTemplateModel]
}

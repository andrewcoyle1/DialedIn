//
//  ProgramTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation

struct ProgramTemplateServices {
    let local: LocalProgramTemplatePersistence
    let remote: RemoteProgramTemplateService
}

// MARK: - Local Persistence Protocol
protocol LocalProgramTemplatePersistence {
    func getAll() -> [ProgramTemplateModel]
    func get(id: String) -> ProgramTemplateModel?
    func save(_ template: ProgramTemplateModel) throws
    func delete(id: String) throws
    func getBuiltInTemplates() -> [ProgramTemplateModel]
}

// MARK: - Remote Service Protocol
protocol RemoteProgramTemplateService {
    func fetchAll() async throws -> [ProgramTemplateModel]
    func fetch(id: String) async throws -> ProgramTemplateModel
    func create(_ template: ProgramTemplateModel) async throws
    func update(_ template: ProgramTemplateModel) async throws
    func delete(id: String) async throws
    func fetchPublicTemplates() async throws -> [ProgramTemplateModel]
}

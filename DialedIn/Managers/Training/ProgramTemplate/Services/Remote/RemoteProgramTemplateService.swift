//
//  RemoteProgramTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

protocol RemoteProgramTemplateService {
    func fetchAll() async throws -> [ProgramTemplateModel]
    func fetch(id: String) async throws -> ProgramTemplateModel
    func create(_ template: ProgramTemplateModel) async throws
    func update(_ template: ProgramTemplateModel) async throws
    func delete(id: String) async throws
    func fetchPublicTemplates() async throws -> [ProgramTemplateModel]
}

//
//  FirebaseProgramTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation
import FirebaseFirestore

class FirebaseProgramTemplateService: RemoteProgramTemplateService {
    
    private let database = Firestore.firestore()
    private let collection = "program_templates"
    
    func fetchAll() async throws -> [ProgramTemplateModel] {
        let snapshot = try await database.collection(collection).getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: ProgramTemplateModel.self)
        }
    }
    
    func fetch(id: String) async throws -> ProgramTemplateModel {
        let document = try await database.collection(collection).document(id).getDocument()
        guard let template = try? document.data(as: ProgramTemplateModel.self) else {
            throw ProgramTemplateError.notFound
        }
        return template
    }
    
    func create(_ template: ProgramTemplateModel) async throws {
        try database.collection(collection).document(template.id).setData(from: template)
    }
    
    func update(_ template: ProgramTemplateModel) async throws {
        try database.collection(collection).document(template.id).setData(from: template, merge: true)
    }
    
    func delete(id: String) async throws {
        try await database.collection(collection).document(id).delete()
    }
    
    func fetchPublicTemplates() async throws -> [ProgramTemplateModel] {
        let snapshot = try await database.collection(collection)
            .whereField("is_public", isEqualTo: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: ProgramTemplateModel.self)
        }
    }
}

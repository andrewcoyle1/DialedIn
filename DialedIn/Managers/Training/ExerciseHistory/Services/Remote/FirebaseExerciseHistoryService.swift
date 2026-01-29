//
//  FirebaseExerciseHistoryService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import FirebaseFirestore

struct FirebaseExerciseHistoryService: RemoteExerciseHistoryService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("exercise_history")
    }
    
    func createExerciseHistory(entry: ExerciseHistoryEntryModel) async throws {
        try collection.document(entry.id).setData(from: entry, merge: true)
    }
    
    func updateExerciseHistory(entry: ExerciseHistoryEntryModel) async throws {
        try collection.document(entry.id).setData(from: entry, merge: true)
    }
    
    func getExerciseHistory(id: String) async throws -> ExerciseHistoryEntryModel {
        try await collection.getDocument(id: id)
    }
    
    func getExerciseHistoryForTemplate(templateId: String, limitTo: Int) async throws -> [ExerciseHistoryEntryModel] {
        try await collection
            .whereField(ExerciseHistoryEntryModel.CodingKeys.templateId.rawValue, isEqualTo: templateId)
            .order(by: ExerciseHistoryEntryModel.CodingKeys.performedAt.rawValue, descending: true)
            .limit(to: limitTo)
            .getAllDocuments()
    }
    
    func getExerciseHistoryForAuthor(authorId: String, limitTo: Int) async throws -> [ExerciseHistoryEntryModel] {
        try await collection
            .whereField(ExerciseHistoryEntryModel.CodingKeys.authorId.rawValue, isEqualTo: authorId)
            .order(by: ExerciseHistoryEntryModel.CodingKeys.performedAt.rawValue, descending: true)
            .limit(to: limitTo)
            .getAllDocuments()
    }
    
    func deleteExerciseHistory(id: String) async throws {
        try await collection.document(id).delete()
    }
    
    func deleteAllExerciseHistoryForAuthor(authorId: String) async throws {
        let docs: [ExerciseHistoryEntryModel] = try await collection
            .whereField(ExerciseHistoryEntryModel.CodingKeys.authorId.rawValue, isEqualTo: authorId)
            .getAllDocuments()
        for doc in docs {
            try await collection.document(doc.id).delete()
        }
    }
}

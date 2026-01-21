//
//  FirebaseTrainingProgramSercice.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import FirebaseFirestore

struct FirebaseTrainingProgramService: RemoteTrainingProgramService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("training_programs")
    }
    
    // MARK: CREATE
    func createTrainingProgram(program: TrainingProgram) async throws {
        try collection.document(program.id).setData(from: program, merge: true)
    }
    
    // MARK: READ
    func readTrainingProgram(programId: String) async throws -> TrainingProgram {
        try await collection.getDocument(id: programId)
    }
    
    func readAllTrainingProgramsForAuthor(userId: String) async throws -> [TrainingProgram] {
        try await collection
            .whereField(TrainingProgram.CodingKeys.authorId.rawValue, isEqualTo: userId)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    // MARK: UPDATE
    func updateTrainingProgram(program: TrainingProgram) async throws {
        try collection.document(program.id).setData(from: program)
    }
    
    // MARK: DELETE
    func deleteTrainingProgram(programId: String) async throws {
        try await collection.document(programId).delete()
    }
}

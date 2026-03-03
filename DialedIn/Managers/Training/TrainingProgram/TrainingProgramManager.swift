//
//  TrainingProgramManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import Foundation

@Observable
@MainActor
class TrainingProgramManager {
    
    private let activeTrainingProgramSyncEngine: DocumentSyncEngine<TrainingProgram>
    private let trainingProgramSyncEngine: CollectionSyncEngine<TrainingProgram>
        
    var activeTrainingProgram: TrainingProgram? {
        activeTrainingProgramSyncEngine.currentDocument
    }
    
    var trainingPrograms: [TrainingProgram] {
        trainingProgramSyncEngine.currentCollection
    }
    
    init(activeTrainingProgramSyncEngine: DocumentSyncEngine<TrainingProgram>, trainingProgramSyncEngine: CollectionSyncEngine<TrainingProgram>) {
        self.activeTrainingProgramSyncEngine = activeTrainingProgramSyncEngine
        self.trainingProgramSyncEngine = trainingProgramSyncEngine
    }
    
    func signIn(programId: String) async throws {
        async let trainingProgramSignIn: () = trainingProgramSyncEngine.startListening()

        if !programId.isEmpty {
            async let activeTrainingProgramSignIn: () = activeTrainingProgramSyncEngine.startListening(documentId: programId)
            try await activeTrainingProgramSignIn
        }

        await trainingProgramSignIn
    }
    
    func setActiveProgram(programId: String) async throws {
        try await activeTrainingProgramSyncEngine.startListening(documentId: programId)
    }

    func signOut() {
        activeTrainingProgramSyncEngine.stopListening()
        trainingProgramSyncEngine.stopListening()
    }
    
    func saveTrainingProgram(trainingProgram: TrainingProgram) async throws {
        try await trainingProgramSyncEngine.saveDocument(trainingProgram)
    }
    
    // MARK: DELETE
        
    func deleteTrainingProgram(programId: String) async throws {
        try await trainingProgramSyncEngine.deleteDocument(id: programId)
    }
}

extension CoreInteractor {
    // MARK: TrainingProgramManager

    var activeTrainingProgram: TrainingProgram? {
        trainingProgramManager.activeTrainingProgram
    }

    var trainingPrograms: [TrainingProgram] {
        trainingProgramManager.trainingPrograms
    }
    
    func saveTrainingProgram(trainingProgram: TrainingProgram) async throws {
        try await trainingProgramManager.saveTrainingProgram(trainingProgram: trainingProgram)
    }
        
    func deleteTrainingProgram(programId: String) async throws {
        try await trainingProgramManager.deleteTrainingProgram(programId: programId)
    }

}

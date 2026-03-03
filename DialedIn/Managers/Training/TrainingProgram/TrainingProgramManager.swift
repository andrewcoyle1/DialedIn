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
    
    private let trainingProgramSyncEngine: CollectionSyncEngine<TrainingProgram>
            
    var trainingPrograms: [TrainingProgram] {
        trainingProgramSyncEngine.currentCollection
    }
    
    init(trainingProgramSyncEngine: CollectionSyncEngine<TrainingProgram>) {
        self.trainingProgramSyncEngine = trainingProgramSyncEngine
    }
    
    func signIn(programId: String) async {
        await trainingProgramSyncEngine.startListening()
    }
    
    func signOut() {
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
        guard let activeTrainingProgramId = currentUser?.submittedActiveTrainingProgramId else { return nil }
        return trainingPrograms.first { program in
            program.id == activeTrainingProgramId
        }
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

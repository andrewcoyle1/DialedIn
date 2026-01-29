//
//  TrainingProgramManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import Foundation

@Observable
class TrainingProgramManager {
    
    private let local: LocalTrainingProgramPersistence
    private let remote: RemoteTrainingProgramService
    private(set) var activeTrainingProgram: TrainingProgram?
    
    init(services: TrainingProgramServices) {
        self.remote = services.remote
        self.local = services.local
    }
    
    // MARK: CREATE
    func createTrainingProgram(program: TrainingProgram) async throws {
        try local.createTrainingProgram(program: program)
        try await remote.createTrainingProgram(program: program)
    }

    // MARK: READ
    
    func readLocalTrainingProgram(programId: String) throws -> TrainingProgram {
        try local.readTrainingProgram(programId: programId)
    }
    
    func readAllLocalTrainingPrograms() throws -> [TrainingProgram] {
        try local.readAllLocalTrainingPrograms()
    }
    
    func readRemoteTrainingProgram(programId: String) async throws -> TrainingProgram {
        try await remote.readTrainingProgram(programId: programId)
    }
    
    func readAllRemoteTrainingProgramsForAuthor(userId: String) async throws -> [TrainingProgram] {
        try await remote.readAllTrainingProgramsForAuthor(userId: userId)
    }

    // MARK: UPDATE
    
    func updateTrainingProgram(program: TrainingProgram) async throws {
        try local.updateTrainingProgram(program: program)
        try await remote.updateTrainingProgram(program: program)
    }

    // MARK: DELETE
        
    func deleteTrainingProgram(program: TrainingProgram) async throws {
        try local.deleteTrainingProgram(program: program)
        try await remote.deleteTrainingProgram(programId: program.id)
    }
}

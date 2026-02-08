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
    
    func readActiveTrainingProgram(programId: String) throws -> TrainingProgram? {
        self.activeTrainingProgram = try local.readTrainingProgram(programId: programId)
        return self.activeTrainingProgram
    }
    
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
    
    // MARK: Sync Operations
    
    /// Syncs training programs from remote Firebase to local storage.
    /// Fetches all programs for the author and upserts into local store.
    func syncTrainingProgramsFromRemote(authorId: String) async throws {
        let remotePrograms = try await remote.readAllTrainingProgramsForAuthor(userId: authorId)
        for program in remotePrograms {
            do {
                _ = try local.readTrainingProgram(programId: program.id)
                try local.updateTrainingProgram(program: program)
            } catch {
                try local.createTrainingProgram(program: program)
            }
        }
    }
    
    /// Uploads local-only training programs to Firebase.
    /// Use when a user has programs that were created before remote sync existed.
    func uploadLocalProgramsToRemote(authorId: String) async throws {
        let localPrograms = try local.readAllLocalTrainingPrograms()
        for program in localPrograms where program.authorId == authorId {
            try? await remote.createTrainingProgram(program: program)
        }
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

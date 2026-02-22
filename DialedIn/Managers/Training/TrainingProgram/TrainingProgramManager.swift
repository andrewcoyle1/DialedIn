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
    
    private let local: LocalTrainingProgramPersistence
    private let remote: RemoteTrainingProgramService
    private(set) var activeTrainingProgram: TrainingProgram?
    
    init(services: TrainingProgramServices) {
        self.remote = services.remote
        self.local = services.local
    }
    
    func readActiveTrainingProgram(programId: String) throws -> TrainingProgram? {
        self.activeTrainingProgram = try local.readTrainingProgram(programId: programId)
        return self.activeTrainingProgram
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

extension CoreInteractor {
    // MARK: TrainingProgramManager
    
    @discardableResult
    func getActiveTrainingProgram() throws -> TrainingProgram? {
        guard let programId = currentUser?.submittedActiveTrainingProgramId else { return nil }
        return try trainingProgramManager.readActiveTrainingProgram(programId: programId)
    }

    var activeTrainingProgram: TrainingProgram? {
        trainingProgramManager.activeTrainingProgram
    }

    // CREATE
    
    func createTrainingProgram(program: TrainingProgram) async throws {
        try await trainingProgramManager.createTrainingProgram(program: program)
    }

    // UPSERT

    func upsertTrainingProgram(program: TrainingProgram) async throws {
        do {
            try await trainingProgramManager.updateTrainingProgram(program: program)
        } catch {
            let urlError = error as? URLError
            if urlError?.code == .fileDoesNotExist {
                try await trainingProgramManager.createTrainingProgram(program: program)
            } else {
                throw error
            }
        }
    }
    
    // READ
    
    func readLocalTrainingProgram(programId: String) throws -> TrainingProgram {
        try trainingProgramManager.readLocalTrainingProgram(programId: programId)
    }
    
    func readAllLocalTrainingPrograms() throws -> [TrainingProgram] {
        try trainingProgramManager.readAllLocalTrainingPrograms()
    }
    
    func readRemoteTrainingProgram(programId: String) async throws -> TrainingProgram {
        try await trainingProgramManager.readRemoteTrainingProgram(programId: programId)
    }
    
    func readAllRemoteTrainingProgramsForAuthor(userId: String) async throws -> [TrainingProgram] {
        try await trainingProgramManager.readAllRemoteTrainingProgramsForAuthor(userId: userId)
    }
    
    // UPDATE
    
    func updateTrainingProgram(program: TrainingProgram) async throws {
        try await trainingProgramManager.updateTrainingProgram(program: program)
    }
    
    // DELETE
    
    func deleteTrainingProgram(program: TrainingProgram) async throws {
        try await trainingProgramManager.deleteTrainingProgram(program: program)
    }

}

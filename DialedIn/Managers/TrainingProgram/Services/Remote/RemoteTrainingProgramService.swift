//
//  RemoteTrainingProgramService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

protocol RemoteTrainingProgramService {
    
    // MARK: CREATE
    func createTrainingProgram(program: TrainingProgram) async throws
    
    // MARK: READ
    func readTrainingProgram(programId: String) async throws -> TrainingProgram
    func readAllTrainingProgramsForAuthor(userId: String) async throws -> [TrainingProgram]
    
    // MARK: UPDATE
    func updateTrainingProgram(program: TrainingProgram) async throws
    
    // MARK: DELETE
    func deleteTrainingProgram(programId: String) async throws
    
}

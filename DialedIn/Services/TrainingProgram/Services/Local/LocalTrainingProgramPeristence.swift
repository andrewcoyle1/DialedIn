//
//  LocalTrainingProgramPeristence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

protocol LocalTrainingProgramPersistence {
    
    // MARK: CREATE
    func createTrainingProgram(program: TrainingProgram) throws
    
    // MARK: READ
    func readTrainingProgram(programId: String) throws -> TrainingProgram
    func readAllLocalTrainingPrograms() throws -> [TrainingProgram]
    
    // MARK: UPDATE
    func updateTrainingProgram(program: TrainingProgram) throws
    
    // MARK: DELETE
    func deleteTrainingProgram(program: TrainingProgram) throws
}

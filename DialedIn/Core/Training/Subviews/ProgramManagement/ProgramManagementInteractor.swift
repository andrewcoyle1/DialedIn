//
//  ProgramManagementInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol ProgramManagementInteractor {
    func readAllLocalTrainingPrograms() throws -> [TrainingProgram]
    func setActiveTrainingProgram(programId: String) async throws
    func deleteTrainingProgram(program: TrainingProgram) async throws
}

extension CoreInteractor: ProgramManagementInteractor { }

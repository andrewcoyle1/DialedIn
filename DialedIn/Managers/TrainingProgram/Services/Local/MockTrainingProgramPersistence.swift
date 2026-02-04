//
//  MockTrainingProgramPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import Foundation

class MockTrainingProgramPersistence: LocalTrainingProgramPersistence {

    var showError: Bool
    var hasActiveTrainingProgram: Bool
    
    private var programs: [String: TrainingProgram] = [:]
    
    init(showError: Bool = false, hasActiveTrainingProgram: Bool = true, customPrograms: [TrainingProgram] = []) {
        self.showError = showError
        self.hasActiveTrainingProgram = hasActiveTrainingProgram
        // Seed with mock data
        for program in customPrograms {
            programs[program.id] = program
        }
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func setActiveTrainingProgram(program: TrainingProgram) throws {
        try tryShowError()
    }

    // MARK: CREATE
    func createTrainingProgram(program: TrainingProgram) throws {
        try tryShowError()
        programs[program.id] = program
    }

    // MARK: READ
    
    func getActiveTrainingProgram() throws -> TrainingProgram? {
        try tryShowError()
        
        if hasActiveTrainingProgram {
            return TrainingProgram.mock
        } else {
            return nil
        }
    }
        
    func readTrainingProgram(programId: String) throws -> TrainingProgram {
        try tryShowError()

        return programs[programId] ?? TrainingProgram.mock
    }
    
    func readAllLocalTrainingPrograms() throws -> [TrainingProgram] {
        try tryShowError()

        if programs.isEmpty {
            return TrainingProgram.mocks
        }
        return Array(programs.values)
    }

    // MARK: UPDATE
    func updateTrainingProgram(program: TrainingProgram) throws {
        try tryShowError()
        guard programs[program.id] != nil else {
            throw URLError(.fileDoesNotExist)
        }
        programs[program.id] = program
    }

    // MARK: DELETE
    func deleteTrainingProgram(program: TrainingProgram) throws {
        programs[program.id] = nil
    }
}

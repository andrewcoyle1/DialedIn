//
//  MockTrainingProgramPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import Foundation

class MockTrainingProgramPersistence: LocalTrainingProgramPersistence {
    
    var showError: Bool
    
    private var programs: [String: TrainingProgram] = [:]
    
    init(showError: Bool = false, customPrograms: [TrainingProgram] = []) {
        self.showError = showError
        
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
}

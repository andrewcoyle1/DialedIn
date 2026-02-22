//
//  MockTrainingProgramService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import Foundation

struct MockTrainingProgramService: RemoteTrainingProgramService {
    
    let delay: Double
    let showError: Bool
    private var remotePrograms: [String: TrainingProgram] = [:]
    
    init(delay: Double = 0.0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createTrainingProgram(program: TrainingProgram) async throws {
        try tryShowError()
    }
    
    func readTrainingProgram(programId: String) async throws -> TrainingProgram {
        try tryShowError()
        
        return TrainingProgram.mocks.first(where: { $0.id == programId}) ?? TrainingProgram.mock
    }
    
    func readAllTrainingProgramsForAuthor(userId: String) async throws -> [TrainingProgram] {
        try tryShowError()

        return TrainingProgram.mocks
    }
    
    func updateTrainingProgram(program: TrainingProgram) async throws {
        try tryShowError()

    }
    
    func deleteTrainingProgram(programId: String) async throws {
        try tryShowError()

    }

}

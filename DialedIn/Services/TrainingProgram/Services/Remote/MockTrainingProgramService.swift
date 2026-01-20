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
}

//
//  MockTrainingProgramServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

struct MockTrainingProgramServices: TrainingProgramServices {
    let local: LocalTrainingProgramPersistence
    let remote: RemoteTrainingProgramService
    
    init(delay: Double = 0, showError: Bool = false, plans: [TrainingProgram] = TrainingProgram.mocks) {
        self.remote = MockTrainingProgramService(delay: delay, showError: showError)
        self.local = MockTrainingProgramPersistence(showError: showError)
    }
}

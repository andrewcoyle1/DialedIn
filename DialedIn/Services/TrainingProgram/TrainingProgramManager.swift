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
    
    init(services: TrainingProgramServices) {
        self.remote = services.remote
        self.local = services.local
    }
}

//
//  ProductionTrainingProgramServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

@MainActor
struct ProductionTrainingProgramServices: TrainingProgramServices {
    
    let local: LocalTrainingProgramPersistence
    let remote: RemoteTrainingProgramService
    
    init() {
        self.local = SwiftTrainingProgramPersistence()
        self.remote = FirebaseTrainingProgramService()
    }
    
}

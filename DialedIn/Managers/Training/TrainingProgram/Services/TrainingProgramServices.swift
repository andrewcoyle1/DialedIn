//
//  TrainingProgramServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

@MainActor
protocol TrainingProgramServices {
    
    var remote: RemoteTrainingProgramService { get }
    var local: LocalTrainingProgramPersistence { get }
    
}

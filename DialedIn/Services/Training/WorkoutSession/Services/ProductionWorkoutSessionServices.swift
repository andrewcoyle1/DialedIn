//
//  ProductionWorkoutSessionServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionWorkoutSessionServices: WorkoutSessionServices {
    let remote: RemoteWorkoutSessionService
    let local: LocalWorkoutSessionPersistence
    
    @MainActor
    init(logManager: LogManager? = nil) {
        self.remote = FirebaseWorkoutSessionService(logManager: logManager)
        self.local = SwiftWorkoutSessionPersistence()
    }
}

//
//  WorkoutSessionServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/09/2025.
//

protocol WorkoutSessionServices {
    var remote: RemoteWorkoutSessionService { get }
    var local: LocalWorkoutSessionPersistence { get }
}

struct MockWorkoutSessionServices: WorkoutSessionServices {
    let remote: RemoteWorkoutSessionService
    let local: LocalWorkoutSessionPersistence
    
    @MainActor
    init(sessions: [WorkoutSessionModel] = WorkoutSessionModel.mocks, delay: Double = 0, showErrorLocal: Bool = false, showErrorRemote: Bool = false, hasActiveSession: Bool = false) {
        self.remote = MockWorkoutSessionService(sessions: sessions, delay: delay, showError: showErrorRemote)
        self.local = MockWorkoutSessionPersistence(sessions: sessions, showError: showErrorLocal, hasActiveSession: hasActiveSession)
    }
}

struct ProductionWorkoutSessionServices: WorkoutSessionServices {
    let remote: RemoteWorkoutSessionService
    let local: LocalWorkoutSessionPersistence
    
    @MainActor
    init(logManager: LogManager? = nil) {
        self.remote = FirebaseWorkoutSessionService(logManager: logManager)
        self.local = SwiftWorkoutSessionPersistence()
    }
}

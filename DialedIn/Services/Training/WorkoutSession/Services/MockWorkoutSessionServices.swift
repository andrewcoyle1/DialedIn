//
//  MockWorkoutSessionServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockWorkoutSessionServices: WorkoutSessionServices {
    let remote: RemoteWorkoutSessionService
    let local: LocalWorkoutSessionPersistence
    
    init(sessions: [WorkoutSessionModel] = WorkoutSessionModel.mocks, delay: Double = 0, showErrorLocal: Bool = false, showErrorRemote: Bool = false, hasActiveSession: Bool = false) {
        self.remote = MockWorkoutSessionService(sessions: sessions, delay: delay, showError: showErrorRemote)
        self.local = MockWorkoutSessionPersistence(sessions: sessions, showError: showErrorLocal, hasActiveSession: hasActiveSession)
    }
}

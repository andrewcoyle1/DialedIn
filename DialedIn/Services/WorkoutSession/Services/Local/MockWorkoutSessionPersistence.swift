//
//  MockWorkoutSessionPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import Foundation

@MainActor
struct MockWorkoutSessionPersistence: LocalWorkoutSessionPersistence {
    
    var workoutSessions: [WorkoutSessionModel]
    var showError: Bool
    var activeSession: WorkoutSessionModel?
    
    init(sessions: [WorkoutSessionModel] = WorkoutSessionModel.mocks, showError: Bool = false, hasActiveSession: Bool = false) {
        self.workoutSessions = sessions
        self.showError = showError
        self.activeSession = hasActiveSession ? sessions.first : nil
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func addLocalWorkoutSession(session: WorkoutSessionModel) throws {
        try tryShowError()
    }
    
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws {
        try tryShowError()
    }
    
    func endLocalWorkoutSession(id: String, at endedAt: Date) throws {
        try tryShowError()
    }
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel {
        try tryShowError()

        if let session = workoutSessions.first(where: { $0.id == id }) {
            return session
        } else {
            throw NSError(domain: "MockWorkoutSessionPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutSession with id \(id) not found"])
        }
    }
    func getLocalWorkoutSessions(ids: [String]) throws -> [WorkoutSessionModel] {
        try tryShowError()

        return workoutSessions.filter { ids.contains($0.id) }
    }
    
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel] {
        try tryShowError()
        let filtered = workoutSessions.filter { $0.authorId == authorId }
        return Array(filtered.prefix(limitTo))
    }
    
    func getAllLocalWorkoutSessions() throws -> [WorkoutSessionModel] {
        try tryShowError()

        return workoutSessions
    }
    
    func deleteLocalWorkoutSession(id: String) throws {
        try tryShowError()
    }
    
    func deleteAllLocalWorkoutSessionsForAuthor(authorId: String) throws {
        try tryShowError()
    }
    
    // MARK: - Active Session
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel? {
        try tryShowError()
        return activeSession
    }
    
    func setActiveLocalWorkoutSession(_ session: WorkoutSessionModel?) throws {
        try tryShowError()
        // In-memory assignment occurs via value semantics; no persistent backing needed for mock
    }
    
}

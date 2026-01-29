//
//  MockExerciseTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct MockWorkoutSessionService: RemoteWorkoutSessionService {
    let sessions: [WorkoutSessionModel]
    let delay: Double
    let showError: Bool
    
    init(sessions: [WorkoutSessionModel] = WorkoutSessionModel.mocks, delay: Double = 0.0, showError: Bool = false) {
        self.sessions = sessions
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    // Create
    func createWorkoutSession(session: WorkoutSessionModel) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    // Read
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        guard let session = sessions.first(where: { $0.id == id}) else {
            throw URLError(.unknown)
        }
        
        return session
    }
    
    func getWorkoutSessions(ids: [String], limitTo: Int) async throws -> [WorkoutSessionModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
                
        return sessions
    }
    
    func getWorkoutSessionsByTemplateAndAuthor(templateId: String, authorId: String, limitTo: Int) async throws -> [WorkoutSessionModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
                
        return sessions
    }
    
    func getWorkoutSessionsForAuthor(authorId: String, limitTo: Int) async throws -> [WorkoutSessionModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
                
        return sessions
    }
    
    func getLastCompletedSessionForTemplate(templateId: String, authorId: String) async throws -> WorkoutSessionModel? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        // Return the first completed session matching the template
        return sessions.first { session in
            session.workoutTemplateId == templateId &&
            session.authorId == authorId &&
            session.endedAt != nil
        }
    }
    
    // Update
    func updateWorkoutSession(session: WorkoutSessionModel) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func endWorkoutSession(id: String, at endedAt: Date) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    // Delete
    func deleteWorkoutSession(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func deleteAllWorkoutSessionsForAuthor(authorId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
}

//
//  WorkoutSessionManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@MainActor
@Observable
class WorkoutSessionManager: LocalWorkoutSessionPersistence, RemoteWorkoutSessionService {
    
    private let local: LocalWorkoutSessionPersistence
    private let remote: RemoteWorkoutSessionService
    
    // MARK: - UI Presentation State
    // Currently active (in-progress) workout session the user can resume
    var activeSession: WorkoutSessionModel?
    
    // Controls presentation of the full screen tracker UI
    var isTrackerPresented: Bool = false
    
    // Rest timer state for active session
    var restEndTime: Date?
    
    // Optional reference to TrainingPlanManager for auto-completion
    weak var trainingPlanManager: TrainingPlanManager?
    
    init(services: WorkoutSessionServices) {
        self.remote = services.remote
        self.local = services.local
    }
    
    // MARK: - Active Session Controls
    func startActiveSession(_ session: WorkoutSessionModel) {
        activeSession = session
        // Persist active session locally
        try? local.setActiveLocalWorkoutSession(session)
        // Do not auto-present here to avoid double presentation when started from a view that already presents the tracker
        isTrackerPresented = false
    }
    
    func minimizeActiveSession() {
        isTrackerPresented = false
    }
    
    func reopenActiveSession() {
        // Always refresh from local to ensure we have the latest edits
        activeSession = try? local.getActiveLocalWorkoutSession()
        guard activeSession != nil else { return }
        isTrackerPresented = true
    }
    
    func endActiveSession(markScheduledComplete: Bool = true) async {
        // Mark scheduled workout as complete if linked to training plan AND not discarding
        if markScheduledComplete,
           let session = activeSession,
           let scheduledWorkoutId = session.scheduledWorkoutId,
           let trainingPlanManager = trainingPlanManager {
            try? await trainingPlanManager.completeWorkout(
                scheduledWorkoutId: scheduledWorkoutId,
                session: session
            )
        }
        
        activeSession = nil
        isTrackerPresented = false
        restEndTime = nil
        // Clear persisted active session
        try? local.setActiveLocalWorkoutSession(nil)
    }

    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel? {
        try local.getActiveLocalWorkoutSession()
    }

    func setActiveLocalWorkoutSession(_ session: WorkoutSessionModel?) throws {
        try local.setActiveLocalWorkoutSession(session)
    }

    // MARK: - Remote Operations

    // Create
    func addLocalWorkoutSession(session: WorkoutSessionModel) throws {
        try local.addLocalWorkoutSession(session: session)
    }
    
    // Read
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel {
        try local.getLocalWorkoutSession(id: id)
    }
    
    func getLocalWorkoutSessions(ids: [String]) throws -> [WorkoutSessionModel] {
        try local.getLocalWorkoutSessions(ids: ids)
    }
    
    func getAllLocalWorkoutSessions() throws -> [WorkoutSessionModel] {
        try local.getAllLocalWorkoutSessions()
    }
    
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel] {
        try local.getLocalWorkoutSessionsForAuthor(authorId: authorId, limitTo: limitTo)
    }
    
    // Update
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws {
        try local.updateLocalWorkoutSession(session: session)
    }
    
    func endLocalWorkoutSession(id: String, at endedAt: Date) throws {
        try local.endLocalWorkoutSession(id: id, at: endedAt)
    }
    
    // Delete
    func deleteLocalWorkoutSession(id: String) throws {
        try local.deleteLocalWorkoutSession(id: id)
    }
    
    func deleteAllLocalWorkoutSessionsForAuthor(authorId: String) throws {
        try local.deleteAllLocalWorkoutSessionsForAuthor(authorId: authorId)
    }
    
    // MARK: - Remote Operations
    
    // Create
    func createWorkoutSession(session: WorkoutSessionModel) async throws {
        try await remote.createWorkoutSession(session: session)
    }
    
    // Read
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel {
        try await remote.getWorkoutSession(id: id)
    }
    
    func getWorkoutSessions(ids: [String], limitTo: Int = 20) async throws -> [WorkoutSessionModel] {
        try await remote.getWorkoutSessions(ids: ids, limitTo: limitTo)
    }
    
    func getWorkoutSessionsByTemplateAndAuthor(templateId: String, authorId: String, limitTo: Int) async throws -> [WorkoutSessionModel] {
        try await remote.getWorkoutSessionsByTemplateAndAuthor(templateId: templateId, authorId: authorId, limitTo: limitTo)
    }
    
    func getWorkoutSessionsForAuthor(authorId: String, limitTo: Int = 20) async throws -> [WorkoutSessionModel] {
        try await remote.getWorkoutSessionsForAuthor(authorId: authorId, limitTo: limitTo)
    }
    
    func getLastCompletedSessionForTemplate(templateId: String, authorId: String) async throws -> WorkoutSessionModel? {
        try await remote.getLastCompletedSessionForTemplate(templateId: templateId, authorId: authorId)
    }
    
    // Update
    func updateWorkoutSession(session: WorkoutSessionModel) async throws {
        try await remote.updateWorkoutSession(session: session)
    }
    
    func endWorkoutSession(id: String, at endedAt: Date) async throws {
        try await remote.endWorkoutSession(id: id, at: endedAt)
    }
    
    // Delete
    func deleteWorkoutSession(id: String) async throws {
        try await remote.deleteWorkoutSession(id: id)
    }
    
    func deleteAllWorkoutSessionsForAuthor(authorId: String) async throws {
        try await remote.deleteAllWorkoutSessionsForAuthor(authorId: authorId)
    }
}

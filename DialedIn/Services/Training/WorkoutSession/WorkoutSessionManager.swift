//
//  WorkoutSessionManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@Observable
class WorkoutSessionManager {
    
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
    
    // Tracks when sessions are modified (for UI refresh triggers)
    var sessionsLastModified: Date = Date()
    
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
        print("🔄 WorkoutSessionManager.reopenActiveSession() invoked")
        // Always refresh from local to ensure we have the latest edits
        activeSession = try? local.getActiveLocalWorkoutSession()
        if let session = activeSession {
            print("✅ Active session restored for reopen (id=\(session.id), name=\(session.name))")
        } else {
            print("⚠️ No active session found to reopen")
        }
        guard activeSession != nil else { return }
        isTrackerPresented = true
    }
    
    func endActiveSession(markScheduledComplete: Bool = true) async {
        // Mark scheduled workout as complete if linked to training plan AND not discarding
        if markScheduledComplete,
           let session = activeSession,
           let trainingPlanManager = trainingPlanManager {
            if let scheduledWorkoutId = session.scheduledWorkoutId {
                // Direct link - mark the specific scheduled workout complete
                try? await trainingPlanManager.completeWorkout(
                    scheduledWorkoutId: scheduledWorkoutId,
                    session: session
                )
            } else if let templateId = session.workoutTemplateId {
                // Fallback: if no explicit link, try to find a scheduled workout for today
                // matching this template that is not yet completed
                let todays = trainingPlanManager.getTodaysWorkouts()
                if let match = todays.first(where: { !$0.isCompleted && $0.workoutTemplateId == templateId }) {
                    try? await trainingPlanManager.completeWorkout(
                        scheduledWorkoutId: match.id,
                        session: session
                    )
                }
            }
        }
        
        // Save completed session locally for offline history
        if let session = activeSession, session.endedAt != nil {
            try? local.updateLocalWorkoutSession(session: session)
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

    // MARK: - Local Operations

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
        sessionsLastModified = Date()
    }
    
    func deleteAllLocalWorkoutSessionsForAuthor(authorId: String) throws {
        try local.deleteAllLocalWorkoutSessionsForAuthor(authorId: authorId)
        sessionsLastModified = Date()
    }
    
    // MARK: - Remote Operations
    
    // Create
    func createWorkoutSession(session: WorkoutSessionModel) async throws {
        try await remote.createWorkoutSession(session: session)
        sessionsLastModified = Date()
    }
    
    // Read
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel {
        try await remote.getWorkoutSession(id: id)
    }
    
    /// Get workout session, trying local storage first, then falling back to remote
    func getWorkoutSessionWithFallback(id: String) async throws -> WorkoutSessionModel {
        // Try local first
        if let cachedSession = try? local.getLocalWorkoutSession(id: id) {
            return cachedSession
        }
        
        // Fetch from remote
        let remoteSession = try await remote.getWorkoutSession(id: id)
        
        // Cache locally for future use
        try? local.upsertLocalWorkoutSession(session: remoteSession)
        
        return remoteSession
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
        sessionsLastModified = Date()
    }
    
    func endWorkoutSession(id: String, at endedAt: Date) async throws {
        try await remote.endWorkoutSession(id: id, at: endedAt)
        sessionsLastModified = Date()
    }
    
    // Delete
    func deleteWorkoutSession(id: String) async throws {
        try await remote.deleteWorkoutSession(id: id)
        sessionsLastModified = Date()
    }
    
    func deleteAllWorkoutSessionsForAuthor(authorId: String) async throws {
        try await remote.deleteAllWorkoutSessionsForAuthor(authorId: authorId)
        sessionsLastModified = Date()
    }
    
    // MARK: - Sync Operations
    
    /// Syncs workout sessions from remote Firebase to local storage
    /// Fetches recent sessions and upserts them into local store
    func syncWorkoutSessionsFromRemote(authorId: String, limitTo: Int = 100) async throws {
        let remoteSessions = try await remote.getWorkoutSessionsForAuthor(authorId: authorId, limitTo: limitTo)
        var failedSessions: [(id: String, error: Error)] = []
        
        for session in remoteSessions {
            do {
                // Upsert: create if not exists or update if exists
                try local.upsertLocalWorkoutSession(session: session)
            } catch {
                // Log individual failures but continue syncing other sessions
                failedSessions.append((id: session.id, error: error))
            }
        }
        
        // Sync scheduled workouts with completed sessions
        if let trainingPlanManager = trainingPlanManager {
            try? await trainingPlanManager.syncScheduledWorkoutsWithCompletedSessions(
                completedSessions: remoteSessions
            )
        }
        
        // If any sessions failed to sync, throw aggregate error
        if !failedSessions.isEmpty {
            let errorMessage = "Failed to sync \(failedSessions.count) of \(remoteSessions.count) sessions"
            let userInfo: [String: Any] = [
                NSLocalizedDescriptionKey: errorMessage,
                "failed_session_ids": failedSessions.map { $0.id },
                "failed_session_count": failedSessions.count,
                "total_session_count": remoteSessions.count
            ]
            throw NSError(domain: "WorkoutSessionManager", code: 500, userInfo: userInfo)
        }
    }
}

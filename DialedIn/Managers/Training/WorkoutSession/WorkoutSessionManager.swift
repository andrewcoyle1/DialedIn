//
//  WorkoutSessionManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutSessionManager {
    
    private let local: LocalWorkoutSessionPersistence
    private let remote: RemoteWorkoutSessionService
    
    // MARK: - UI Presentation State
    // Currently active (in-progress) workout session the user can resume
    var activeSession: WorkoutSessionModel?

    // Rest timer state for active session
    var restEndTime: Date?
        
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
    }

    func endActiveSession(markScheduledComplete: Bool = true) async {
        // Save completed session locally for offline history
        if let session = activeSession, session.endedAt != nil {
            try? local.updateLocalWorkoutSession(session: session)
        }
        
        activeSession = nil
        restEndTime = nil
        // Clear persisted active session
        try? local.setActiveLocalWorkoutSession(nil)
    }

    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel? {
        self.activeSession = try local.getActiveLocalWorkoutSession()
        return activeSession
    }

    func setActiveLocalWorkoutSession(_ session: WorkoutSessionModel?) throws {
        try local.setActiveLocalWorkoutSession(session)
        self.activeSession = session
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
    
    func getWorkoutSessionsForAuthor(authorId: String, limitTo: Int = 20, includeDeleted: Bool = false) async throws -> [WorkoutSessionModel] {
        try await remote.getWorkoutSessionsForAuthor(authorId: authorId, limitTo: limitTo, includeDeleted: includeDeleted)
    }
    
    func getLastCompletedSessionForTemplate(templateId: String, authorId: String) async throws -> WorkoutSessionModel? {
        print("🔍 [getLastCompletedSessionForTemplate] Searching for template: \(templateId), authorId: \(authorId)")
        
        // Try local storage first
        do {
            print("   📱 Checking local storage...")
            let localSessions = try local.getLocalWorkoutSessionsForAuthor(authorId: authorId, limitTo: 0)
            print("   📱 Found \(localSessions.count) total local sessions")
            
            // Debug: Log details about all local sessions
            for (index, session) in localSessions.enumerated() {
                let hasEndedAt = session.endedAt != nil
                let templateMatch = session.workoutTemplateId == templateId
                print("   📱 Session \(index + 1): id=\(session.id), templateId=\(session.workoutTemplateId ?? "nil"), endedAt=\(hasEndedAt ? "\(session.endedAt!)" : "nil"), match=\(templateMatch ? "✅" : "❌")")
            }
            
            // First try exact template ID match
            let matchingSessions = localSessions
                .filter { session in
                    session.workoutTemplateId == templateId && session.endedAt != nil
                }
                .sorted { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }
            
            print("   📱 Found \(matchingSessions.count) matching completed sessions by exact template ID")
            
            if let mostRecent = matchingSessions.first {
                print("   ✅ [getLastCompletedSessionForTemplate] Found local session: \(mostRecent.id), templateId: \(mostRecent.workoutTemplateId ?? "nil"), endedAt: \(mostRecent.endedAt?.description ?? "nil")")
                return mostRecent
            } else {
                print("   ⚠️ [getLastCompletedSessionForTemplate] No exact template ID match found - returning nil for exercise-based matching")
            }
        } catch {
            // Log error but continue to remote fallback
            print("   ⚠️ [getLastCompletedSessionForTemplate] Error querying local storage: \(error)")
        }
        
        // Fall back to remote query
        print("   🌐 Falling back to remote query...")
        do {
            let remoteSession = try await remote.getLastCompletedSessionForTemplate(templateId: templateId, authorId: authorId)
            if let session = remoteSession {
                print("   ✅ [getLastCompletedSessionForTemplate] Found remote session: \(session.id)")
            } else {
                print("   ⚠️ [getLastCompletedSessionForTemplate] No remote session found")
            }
            return remoteSession
        } catch {
            print("   ❌ [getLastCompletedSessionForTemplate] Error querying remote: \(error)")
            throw error
        }
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
        let remoteSessions = try await remote.getWorkoutSessionsForAuthor(authorId: authorId, limitTo: limitTo, includeDeleted: true)
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

extension CoreInteractor {
    // MARK: WorkoutSessionManager
    
    var activeSession: WorkoutSessionModel? {
        workoutSessionManager.activeSession
    }

    var restEndTime: Date? {
        workoutSessionManager.restEndTime
    }
    
    var sessionLastModified: Date? {
        workoutSessionManager.sessionsLastModified
    }
    
    func setActiveSession(_ session: WorkoutSessionModel?) {
        workoutSessionManager.activeSession = session
    }

    func startActiveSession(_ session: WorkoutSessionModel) {
        workoutSessionManager.startActiveSession(session)
    }
    
    func endActiveSession(markScheduledComplete: Bool = true) async {
        await workoutSessionManager.endActiveSession(markScheduledComplete: markScheduledComplete)
    }
    
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel? {
        try workoutSessionManager.getActiveLocalWorkoutSession()
    }
    
    func setActiveLocalWorkoutSession(_ session: WorkoutSessionModel?) throws {
        try workoutSessionManager.setActiveLocalWorkoutSession(session)
    }
    
    // Local Operations
    
    // Create
    func addLocalWorkoutSession(session: WorkoutSessionModel) throws {
        try workoutSessionManager.addLocalWorkoutSession(session: session)
    }
    
    // Read
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel {
        try workoutSessionManager.getLocalWorkoutSession(id: id)
    }
    
    func getLocalWorkoutSessions(ids: [String]) throws -> [WorkoutSessionModel] {
        try workoutSessionManager.getLocalWorkoutSessions(ids: ids)
    }
    
    func getAllLocalWorkoutSessions() throws -> [WorkoutSessionModel] {
        try workoutSessionManager.getAllLocalWorkoutSessions()
    }
    
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel] {
        try workoutSessionManager.getLocalWorkoutSessionsForAuthor(authorId: authorId, limitTo: limitTo)
    }
    
    // Update
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws {
        try workoutSessionManager.updateLocalWorkoutSession(session: session)
    }
    
    func endLocalWorkoutSession(id: String, at endedAt: Date) throws {
        try workoutSessionManager.endLocalWorkoutSession(id: id, at: endedAt)
    }
    
    // Delete
    func deleteLocalWorkoutSession(id: String) throws {
        try workoutSessionManager.deleteLocalWorkoutSession(id: id)
    }
    
    func deleteAllLocalWorkoutSessionsForAuthor(authorId: String) throws {
        try workoutSessionManager.deleteAllLocalWorkoutSessionsForAuthor(authorId: authorId)
    }

    // Remote Operations
    
    // Create
    func createWorkoutSession(session: WorkoutSessionModel) async throws {
        try await workoutSessionManager.createWorkoutSession(session: session)
    }
    
    // Read
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel {
        try await workoutSessionManager.getWorkoutSession(id: id)
    }
    
    /// Get workout session, trying local storage first, then falling back to remote
    func getWorkoutSessionWithFallback(id: String) async throws -> WorkoutSessionModel {
        try await workoutSessionManager.getWorkoutSessionWithFallback(id: id)
    }
    
    func getWorkoutSessions(ids: [String], limitTo: Int = 20) async throws -> [WorkoutSessionModel] {
        try await workoutSessionManager.getWorkoutSessions(ids: ids, limitTo: limitTo)
    }
    
    func getWorkoutSessionsByTemplateAndAuthor(templateId: String, authorId: String, limitTo: Int) async throws -> [WorkoutSessionModel] {
        try await workoutSessionManager.getWorkoutSessionsByTemplateAndAuthor(templateId: templateId, authorId: authorId, limitTo: limitTo)
    }
    
    func getWorkoutSessionsForAuthor(authorId: String, limitTo: Int = 20) async throws -> [WorkoutSessionModel] {
        try await workoutSessionManager.getWorkoutSessionsForAuthor(authorId: authorId, limitTo: limitTo)
    }
    
    func getLastCompletedSessionForTemplate(templateId: String, authorId: String) async throws -> WorkoutSessionModel? {
        try await workoutSessionManager.getLastCompletedSessionForTemplate(templateId: templateId, authorId: authorId)
    }
    
    // Update
    func updateWorkoutSession(session: WorkoutSessionModel) async throws {
        try await workoutSessionManager.updateWorkoutSession(session: session)
    }
    
    func endWorkoutSession(id: String, at endedAt: Date) async throws {
        try await workoutSessionManager.endWorkoutSession(id: id, at: endedAt)
    }
    
    // Delete
    func deleteWorkoutSession(id: String) async throws {
        try await workoutSessionManager.deleteWorkoutSession(id: id)
    }

    func deleteAllWorkoutSessionsForAuthor(authorId: String) async throws {
        try await workoutSessionManager.deleteAllWorkoutSessionsForAuthor(authorId: authorId)
    }
    
    // Sync Operations
    
    /// Syncs workout sessions from remote Firebase to local storage
    /// Fetches recent sessions and upserts them into local store
    func syncWorkoutSessionsFromRemote(authorId: String, limitTo: Int = 100) async throws {
        try await workoutSessionManager.syncWorkoutSessionsFromRemote(authorId: authorId, limitTo: limitTo)
    }

}

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

    private let activeWorkoutSessionPersistence: any LocalDocumentPersistence<WorkoutSessionModel>
    
    private let userWorkoutSessionSyncEngine: CollectionSyncEngine<WorkoutSessionModel>
    private let followingWorkoutSessionSyncEngine: CollectionGroupSyncEngine<WorkoutSessionModel>
    
    // MARK: - Observable State

    var activeSession: WorkoutSessionModel?

    var workoutSessions: [WorkoutSessionModel] {
        userWorkoutSessionSyncEngine.currentCollection
    }
    
    var followingWorkoutSessions: [WorkoutSessionModel] {
        followingWorkoutSessionSyncEngine.currentCollection
    }

    var restEndTime: Date?

    // MARK: - Init

    init(
        activeWorkoutSessionPersistence: any LocalDocumentPersistence<WorkoutSessionModel>,
        userWorkoutSessionSyncEngine: CollectionSyncEngine<WorkoutSessionModel>,
        followingWorkoutSessionSyncEngine: CollectionGroupSyncEngine<WorkoutSessionModel>
    ) {
        self.activeWorkoutSessionPersistence = activeWorkoutSessionPersistence
        self.userWorkoutSessionSyncEngine = userWorkoutSessionSyncEngine
        self.followingWorkoutSessionSyncEngine = followingWorkoutSessionSyncEngine
        self.activeSession = try? activeWorkoutSessionPersistence.getDocument(managerKey: "active_session")
    }
    
    // MARK: - Lifecycle

    func signIn(userId: String, followingIds: [String] = []) async {
        async let userWorkoutsSignIn: () = userWorkoutSessionSyncEngine.startListening { query in
            query.where("author_id", isEqualTo: userId)
        }

        await userWorkoutsSignIn
        await refreshFollowingSync(followingIds: followingIds)
    }

    func refreshFollowingSync(followingIds: [String]) async {
        guard !followingIds.isEmpty else {
            followingWorkoutSessionSyncEngine.stopListening()
            return
        }
        await followingWorkoutSessionSyncEngine.startListening { query in
            query.where("author_id", in: followingIds)
        }
    }

    func signOut() {
        userWorkoutSessionSyncEngine.stopListening()
        followingWorkoutSessionSyncEngine.stopListening()
    }

    func updateActiveSession(_ session: WorkoutSessionModel) throws {
        try activeWorkoutSessionPersistence.saveDocument(managerKey: "active_session", session)
        self.activeSession = session
    }
    
    func endWorkoutSession(_ session: WorkoutSessionModel) async throws {
        try await self.saveWorkoutSession(session)
        try clearActiveSession()
    }
    
    func deleteActiveSession() throws {
        try clearActiveSession()
    }
    
    private func clearActiveSession() throws {
        try activeWorkoutSessionPersistence.saveDocument(managerKey: "active_session", nil)
        self.activeSession = nil
    }
    
    func getLastWorkoutSessionForTemplate(templateId: String) async throws -> WorkoutSessionModel? {
        let sessions = try await userWorkoutSessionSyncEngine.getDocumentsAsync { session in
            session.workoutTemplateId == templateId
        }
        return sessions.sortedByKeyPath(keyPath: \.dateCreated, ascending: false).first
    }

    // MARK: - Write

    func saveWorkoutSession(_ session: WorkoutSessionModel) async throws {
        try await userWorkoutSessionSyncEngine.saveDocument(session)
    }

    func deleteWorkoutSession(id: String) async throws {
        try await userWorkoutSessionSyncEngine.deleteDocument(id: id)
    }

    func deleteAllWorkoutSessionsForAuthor(authorId: String) async throws {
        for workoutSession in workoutSessions.filter({ $0.authorId == authorId }) {
            try await userWorkoutSessionSyncEngine.deleteDocument(id: workoutSession.id)
        }
    }

    // MARK: - Read

    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel {
        try await userWorkoutSessionSyncEngine.getDocumentAsync(id: id)
    }

    func getWorkoutSessions(ids: [String], limitTo: Int = 20) -> [WorkoutSessionModel] {
        let results = userWorkoutSessionSyncEngine.getDocuments(where: { ids.contains($0.id) })
        return Array(results.prefix(limitTo))
    }

    func getWorkoutSessionsByTemplateAndAuthor(templateId: String, authorId: String, limitTo: Int) async throws -> [WorkoutSessionModel] {
        try await userWorkoutSessionSyncEngine.getDocumentsAsync { query in
            query
                .where("workout_template_id", isEqualTo: templateId)
                .where("author_id", isEqualTo: authorId)
                .limit(to: limitTo)
        }
    }

    func getWorkoutSessionsForAuthor(authorId: String, limitTo: Int = 20) async throws -> [WorkoutSessionModel] {
        try await userWorkoutSessionSyncEngine.getDocumentsAsync { query in
            query
                .where("author_id", isEqualTo: authorId)
                .limit(to: limitTo)
        }
    }

    func getLastCompletedSessionForTemplate(templateId: String, authorId: String) async throws -> WorkoutSessionModel? {
        // Check the already-loaded collection first (current user's sessions)
        let cached = userWorkoutSessionSyncEngine.currentCollection
            .filter { $0.workoutTemplateId == templateId && $0.endedAt != nil }
            .sorted { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }

        if let mostRecent = cached.first {
            return mostRecent
        }

        return nil
    }
}

extension CoreInteractor {
    // MARK: WorkoutSessionManager

    var activeSession: WorkoutSessionModel? {
        workoutSessionManager.activeSession
    }
    
    func updateActiveSession(_ session: WorkoutSessionModel) throws {
        try workoutSessionManager.updateActiveSession(session)
    }

    var workoutSessions: [WorkoutSessionModel] {
        workoutSessionManager.workoutSessions
    }

    var followingWorkoutSessions: [WorkoutSessionModel] {
        workoutSessionManager.followingWorkoutSessions
    }

    var restEndTime: Date? {
        workoutSessionManager.restEndTime
    }

    func endWorkoutSession(_ session: WorkoutSessionModel) async throws {
        try await workoutSessionManager.endWorkoutSession(session)
    }
    
    func saveWorkoutSession(_ session: WorkoutSessionModel) async throws {
        try await workoutSessionManager.saveWorkoutSession(session)
    }

    func deleteWorkoutSession(id: String) async throws {
        try await workoutSessionManager.deleteWorkoutSession(id: id)
    }

    func deleteAllWorkoutSessionsForAuthor(authorId: String) async throws {
        try await workoutSessionManager.deleteAllWorkoutSessionsForAuthor(authorId: authorId)
    }

    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel {
        try await workoutSessionManager.getWorkoutSession(id: id)
    }

    func getLastWorkoutSessionForTemplate(templateId: String) async throws -> WorkoutSessionModel? {
        try await workoutSessionManager.getLastWorkoutSessionForTemplate(templateId: templateId)
    }
    
    func getWorkoutSessions(ids: [String], limitTo: Int = 20) -> [WorkoutSessionModel] {
        workoutSessionManager.getWorkoutSessions(ids: ids, limitTo: limitTo)
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
}

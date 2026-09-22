//
//  GoalManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

@Observable
@MainActor
class GoalManager {
    
    private let userGoalSyncEngine: DocumentSyncEngine<WeightGoal>

    /// Held so `deleteGoal` can put the listener back. The engine keeps its own document id but
    /// gives no way to restart from it.
    private var listeningUserId: String?
    
    var currentGoal: WeightGoal? {
        userGoalSyncEngine.currentDocument
    }
    
    init(userGoalSyncEngine: DocumentSyncEngine<WeightGoal>) {
        self.userGoalSyncEngine = userGoalSyncEngine
    }
    
    // MARK: - Public Methods
    
    func signIn(userId id: String) async throws {
        try await userGoalSyncEngine.startListening(documentId: id)
        listeningUserId = id
    }
    
    func signOut() {
        userGoalSyncEngine.stopListening()
        listeningUserId = nil
    }
    
    func saveGoal(_ goal: WeightGoal) async throws {
        try await userGoalSyncEngine.saveDocument(goal)
    }
    
    /// `DocumentSyncEngine.deleteDocument` stops its listener and does not start it again, so
    /// without this a goal saved after a delete never reaches `currentGoal` — the write lands
    /// remotely with nothing listening for it, until the next sign-in.
    func deleteGoal() async throws {
        try await userGoalSyncEngine.deleteDocument()

        if let listeningUserId {
            try await userGoalSyncEngine.startListening(documentId: listeningUserId)
        }
    }
    
    /// Mark a goal as completed
    func completeGoal() async throws {
        try await self.updateGoalStatus(.completed)
    }
    
    /// Mark a goal as abandoned
    func abandonGoal() async throws {
        try await self.updateGoalStatus(.abandoned)
    }
        
    /// Pause a goal
    func pauseGoal() async throws {
        try await self.updateGoalStatus(.paused)
    }
    
    /// Resume a goal
    func resumeGoal() async throws {
        try await self.updateGoalStatus(.active)
    }
    
    private func updateGoalStatus(_ status: WeightGoal.GoalStatus) async throws {
        try await userGoalSyncEngine.updateDocument(
            data: [
                WeightGoal.CodingKeys.status.rawValue: status.rawValue
            ]
        )
    }
}

extension CoreInteractor {
    
    // MARK: GoalManager
    
    var currentGoal: WeightGoal? {
        goalManager.currentGoal
    }
        
    func saveGoal(_ goal: WeightGoal) async throws {
        try await goalManager.saveGoal(goal)
    }
        
    func completeGoal() async throws {
        try await goalManager.completeGoal()
    }
    
    func abandonGoal() async throws {
        try await goalManager.abandonGoal()
    }
    
    func pauseGoal() async throws {
        try await goalManager.pauseGoal()
    }

    func resumeGoal() async throws {
        try await goalManager.resumeGoal()
    }

    /// Delete a goal
    func deleteGoal() async throws {
        try await goalManager.deleteGoal()
    }
}

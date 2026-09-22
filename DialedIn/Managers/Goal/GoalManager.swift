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

    /// Held so the listener can be put back after a delete stops it. The engine keeps its own
    /// document id but gives no way to restart from it.
    private var listeningUserId: String?

    /// `DocumentSyncEngine.deleteDocument` stops its listener and does not start it again, so a
    /// delete leaves the engine pointed at a document with nothing listening to it.
    private var isListening: Bool = false
    
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
        isListening = true
    }
    
    func signOut() {
        userGoalSyncEngine.stopListening()
        listeningUserId = nil
        isListening = false
    }
    
    /// Puts the listener back first when a delete stopped it, so the write has somewhere to land.
    /// Without that, a goal saved after a delete never reaches `currentGoal` — it lands remotely
    /// with nothing listening for it, and stays invisible until the next sign-in.
    func saveGoal(_ goal: WeightGoal) async throws {
        try await startListeningIfStopped()
        try await userGoalSyncEngine.saveDocument(goal)
    }
    
    /// Leaves the listener stopped, and lets the next save put it back.
    ///
    /// The restart belongs there rather than here because of where this is called from: the only
    /// caller is `CoreInteractor.deleteAccount`, which runs it alongside deleting the user profile
    /// and immediately revokes auth. Attaching a fresh listener to the document just deleted, as
    /// the account goes away, gives the engine nothing to read and a failed attach to retry —
    /// 2s, 4s, 8s, and on up to a minute — after the user has gone.
    func deleteGoal() async throws {
        try await userGoalSyncEngine.deleteDocument()
        isListening = false
    }

    private func startListeningIfStopped() async throws {
        guard !isListening, let listeningUserId else { return }
        try await userGoalSyncEngine.startListening(documentId: listeningUserId)
        isListening = true
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
